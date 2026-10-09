/**
 * GrapeMinds Wine API client with a hard monthly budget.
 *
 * Every response is cached on disk and never fetched twice; a ledger counts
 * calls per calendar month and refuses to go past the budget (default 200 of
 * the 250 the free plan allows, keeping a reserve).
 *
 * Key: functions/.env.grapeminds containing  GRAPEMINDS_API_KEY=...
 *
 * Usage (from app/functions):
 *   node scripts/grapeminds.js ping
 *   node scripts/grapeminds.js coverage IN
 *   node scripts/grapeminds.js regions IN
 *   node scripts/grapeminds.js producers IN
 *   node scripts/grapeminds.js wines --region 123 [--color red] [--page 1]
 *   node scripts/grapeminds.js search "Sula Rasa"
 *   node scripts/grapeminds.js wine 456
 *   node scripts/grapeminds.js producer-insights 789
 *   node scripts/grapeminds.js region-insights 123
 *   node scripts/grapeminds.js match        # our wines → GrapeMinds ids, from cache only
 *   node scripts/grapeminds.js report       # cache contents + calls used
 * Add --dry-run to print the request without spending a call.
 * Add --budget 230 to change this month's ceiling.
 */
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const BASE = "https://api.grapeminds.eu/public/v1";
const DIR = path.join(__dirname, "grapeminds-cache");
const LEDGER = path.join(__dirname, "grapeminds-ledger.json");
const ENV = path.join(__dirname, "..", ".env.grapeminds");
const args = process.argv.slice(2);
const flag = (name) => {
  const i = args.indexOf(`--${name}`);
  return i > -1 ? args[i + 1] : undefined;
};
const DRY = args.includes("--dry-run");
const BUDGET = Number(flag("budget") ?? 200);
const positional = args.filter((a, i) => !a.startsWith("--") && !(i > 0 && args[i - 1].startsWith("--") && !["dry-run"].includes(args[i - 1].slice(2))));

function key() {
  if (process.env.GRAPEMINDS_API_KEY) return process.env.GRAPEMINDS_API_KEY;
  if (!fs.existsSync(ENV)) throw new Error(`no key: create ${ENV} with GRAPEMINDS_API_KEY=...`);
  const m = fs.readFileSync(ENV, "utf8").match(/GRAPEMINDS_API_KEY\s*=\s*(\S+)/);
  if (!m) throw new Error("GRAPEMINDS_API_KEY not found in .env.grapeminds");
  return m[1].trim();
}

function ledger() {
  const month = new Date().toISOString().slice(0, 7);
  const l = fs.existsSync(LEDGER) ? JSON.parse(fs.readFileSync(LEDGER, "utf8")) : {};
  if (!l[month]) l[month] = { calls: 0, log: [] };
  return { month, l, save: () => fs.writeFileSync(LEDGER, JSON.stringify(l, null, 2)) };
}

async function call(pathname, params = {}, headers = {}) {
  const url = new URL(BASE + pathname);
  for (const [k, v] of Object.entries(params)) if (v !== undefined && v !== "") url.searchParams.set(k, String(v));
  const id = crypto.createHash("sha1").update(url.toString() + JSON.stringify(headers)).digest("hex").slice(0, 16);
  fs.mkdirSync(DIR, { recursive: true });
  const file = path.join(DIR, `${pathname.replace(/[^a-z0-9]+/gi, "_").replace(/^_/, "")}__${id}.json`);
  if (fs.existsSync(file)) {
    const cached = JSON.parse(fs.readFileSync(file, "utf8"));
    console.error(`cache  ${url} (${path.basename(file)})`);
    return cached.body;
  }
  if (DRY) {
    console.error(`DRY    ${url}  (would cost 1 call)`);
    return null;
  }
  const { month, l, save } = ledger();
  if (l[month].calls >= BUDGET) throw new Error(`budget reached: ${l[month].calls}/${BUDGET} calls in ${month}; raise with --budget only if you mean it`);
  const res = await fetch(url, { headers: { Authorization: `Bearer ${key()}`, Accept: "application/json", ...headers } });
  const text = await res.text();
  l[month].calls++;
  l[month].log.push({ at: new Date().toISOString(), url: url.toString(), status: res.status });
  save();
  let body;
  try { body = JSON.parse(text); } catch { body = { raw: text }; }
  if (!res.ok) {
    console.error(`FAIL ${res.status} ${url}\n${text.slice(0, 400)}`);
    if (res.status === 429) console.error("rate limited: wait and retry (call still counted by them)");
    throw new Error(`HTTP ${res.status}`);
  }
  fs.writeFileSync(file, JSON.stringify({ url: url.toString(), at: new Date().toISOString(), status: res.status, body }, null, 2));
  console.error(`call   ${url}  → ${l[month].calls}/${BUDGET} used this month`);
  return body;
}

const out = (o) => console.log(JSON.stringify(o, null, 2));

async function main() {
  const cmd = positional[0];
  switch (cmd) {
    case "ping": return out(await call("/ping"));
    case "coverage": return out(await call("/coverage", { country: positional[1] ?? "IN", lang: "en" }));
    case "regions": return out(await call("/regions", { country: positional[1] ?? "IN", per_page: 100 }, { "Accept-Language": "en" }));
    case "producers": return out(await call("/producers", { country: positional[1] ?? "IN", per_page: 100, page: flag("page") ?? 1 }));
    case "wines": return out(await call("/wines", { region_id: flag("region"), producer_id: flag("producer"), color: flag("color"), sub_type: flag("sub_type"), per_page: 100, page: flag("page") ?? 1 }));
    case "search": return out(await call("/wines/search", { q: positional.slice(1).join(" "), limit: flag("limit") ?? 100 }));
    case "wine": return out(await call(`/wines/${positional[1]}`, {}, { "Accept-Language": flag("lang") ?? "en" }));
    case "producer-insights": return out(await call(`/producer-insights/${positional[1]}`, { lang: flag("lang") ?? "en" }));
    case "region-insights": return out(await call(`/region-insights/${positional[1]}`, { lang: flag("lang") ?? "en" }));
    case "drinking": return out(await call(`/drinking-periods/${positional[1]}`, { lang: "en" }));
    case "report": return report();
    case "match": return match();
    default:
      console.error("commands: ping | coverage [CC] | regions [CC] | producers [CC] | wines --region id | search <q> | wine id | producer-insights id | region-insights id | drinking id | match | report");
      process.exit(1);
  }
}

function report() {
  const { month, l } = ledger();
  const files = fs.existsSync(DIR) ? fs.readdirSync(DIR) : [];
  const byKind = {};
  for (const f of files) byKind[f.split("__")[0]] = (byKind[f.split("__")[0]] ?? 0) + 1;
  out({ month, callsUsed: l[month].calls, budget: BUDGET, cachedResponses: files.length, byEndpoint: byKind });
}

/** Match our Firestore wines to GrapeMinds rows using only cached list/search responses. */
async function match() {
  const admin = require("firebase-admin");
  admin.initializeApp({ projectId: "winebro" });
  const snap = await admin.firestore().collection("products").get();
  const ours = snap.docs.map((d) => d.data()).filter((p) => /wine/i.test(String(p.category)));
  const files = fs.existsSync(DIR) ? fs.readdirSync(DIR).filter((f) => /^wines(_search)?__/.test(f)) : [];
  const gm = [];
  for (const f of files) {
    const body = JSON.parse(fs.readFileSync(path.join(DIR, f), "utf8")).body;
    const rows = Array.isArray(body?.data) ? body.data : Array.isArray(body) ? body : [];
    for (const r of rows) gm.push({ id: r.id, lwin: r.lwin, name: r.display_name, color: r.color, producer: r.producer?.name ?? r.producer_name, region: r.region?.name });
  }
  const norm = (s) => String(s ?? "").toLowerCase().replace(/[^a-z0-9 ]+/g, " ").replace(/\s+/g, " ").trim();
  const tokens = (s) => new Set(norm(s).split(" ").filter((w) => w.length > 2 && !["wine", "wines", "the", "and"].includes(w)));
  const result = ours.map((p) => {
    const t = tokens(`${p.name} ${p.grapeVariety ?? ""}`);
    let best = null;
    for (const g of gm) {
      const gt = tokens(`${g.producer ?? ""} ${g.name}`);
      let hit = 0;
      for (const w of t) if (gt.has(w)) hit++;
      const score = t.size ? hit / t.size : 0;
      if (!best || score > best.score) best = { ...g, score };
    }
    return { ours: p.id, name: p.name, candidate: best && best.score >= 0.5 ? best : null, bestScore: best?.score ?? 0 };
  });
  const matched = result.filter((r) => r.candidate).length;
  out({ ourWines: ours.length, grapemindsRowsCached: gm.length, matched, unmatched: result.filter((r) => !r.candidate).map((r) => r.name), matches: result.filter((r) => r.candidate) });
  console.error(`${matched}/${ours.length} matched from cache; run wines/search commands to widen, then match again`);
}

main().catch((e) => { console.error(e.message); process.exit(1); });
