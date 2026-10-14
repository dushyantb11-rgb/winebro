/**
 * GrapeMinds connector for the console's Data Cellar.
 *
 * Budget: the free plan allows 250 calls per calendar month. Every call is
 * recorded in integrations/grapeminds (ledger) and no action runs without
 * an estimate the admin confirmed. Responses are cached in Firestore so a
 * call is never paid twice:
 *   grapeminds_cache/{hash}         raw response per URL
 *   grapeminds_wines/{id}           list rows, merged with detail when fetched
 *   grapeminds_producers/{id}
 *   grapeminds_regions/{id}
 *   grapeminds_insights/{kind}_{id} producer / region insights
 *
 * Mapping writes a DRAFT of our product (drafts_products) with
 * openData.grapeminds; the normal preview → publish flow applies. Publishing
 * GrapeMinds-derived fields is blocked until the wine is licensed
 * (POST /licence, metered by GrapeMinds) or the admin records GrapeMinds'
 * written confirmation that our plan allows it (terms.commercialOk).
 */
import { createHash } from "crypto";
import { defineSecret } from "firebase-functions/params";
import { DocumentData, FieldValue } from "firebase-admin/firestore";

export const GRAPEMINDS_KEY = defineSecret("GRAPEMINDS_API_KEY");

const BASE = "https://api.grapeminds.eu/public/v1";
const MONTHLY_LIMIT = 250;
const DEFAULT_BUDGET = 230; // keep a reserve for retries
const LEDGER = ["integrations", "grapeminds"] as const;

export class GmError extends Error {
  constructor(public status: number, message: string, public details?: unknown) {
    super(message);
  }
}

type Db = FirebaseFirestore.Firestore;
type Rec = Record<string, unknown>;
const isRec = (v: unknown): v is Rec => !!v && typeof v === "object" && !Array.isArray(v);
const month = () => new Date().toISOString().slice(0, 7);

// ─── Ledger ──────────────────────────────────────────────────────

async function ledger(db: Db) {
  const ref = db.collection(LEDGER[0]).doc(LEDGER[1]);
  const snap = await ref.get();
  const d = (snap.data() ?? {}) as Rec;
  const m = month();
  const months = isRec(d.months) ? d.months : {};
  const cur = isRec(months[m]) ? (months[m] as Rec) : { calls: 0 };
  return {
    ref,
    month: m,
    used: Number(cur.calls ?? 0),
    budget: Number(d.budget ?? DEFAULT_BUDGET),
    limit: MONTHLY_LIMIT,
    terms: isRec(d.terms) ? d.terms : { commercialOk: false },
    lastCall: d.lastCall ?? null,
  };
}

async function spend(db: Db, by: string, url: string, status: number) {
  const m = month();
  await db.collection(LEDGER[0]).doc(LEDGER[1]).set({
    [`months.${m}.calls`]: FieldValue.increment(1),
    lastCall: { at: FieldValue.serverTimestamp(), by, url, status },
    log: FieldValue.arrayUnion({ at: new Date().toISOString(), by, url: url.replace(BASE, ""), status }),
  }, { merge: true });
}

// ─── HTTP with cache ─────────────────────────────────────────────

async function gmFetch(db: Db, by: string, pathname: string, params: Rec = {}, lang = "en", force = false): Promise<{ body: unknown; cached: boolean }> {
  const url = new URL(BASE + pathname);
  for (const [k, v] of Object.entries(params)) if (v !== undefined && v !== null && v !== "") url.searchParams.set(k, String(v));
  const hash = createHash("sha1").update(url.toString() + "|" + lang).digest("hex").slice(0, 20);
  const cacheRef = db.collection("grapeminds_cache").doc(hash);
  if (!force) {
    const c = await cacheRef.get();
    if (c.exists) return { body: c.get("body"), cached: true };
  }
  const l = await ledger(db);
  if (l.used >= l.budget) throw new GmError(429, `GrapeMinds budget reached for ${l.month}: ${l.used}/${l.budget} calls`);
  const res = await fetch(url, { headers: { Authorization: `Bearer ${GRAPEMINDS_KEY.value()}`, Accept: "application/json", "Accept-Language": lang } });
  const text = await res.text();
  await spend(db, by, url.toString(), res.status);
  let body: unknown;
  try { body = JSON.parse(text); } catch { body = { raw: text }; }
  if (!res.ok) throw new GmError(502, `GrapeMinds answered ${res.status} for ${pathname}`, body);
  await cacheRef.set({ url: url.toString(), lang, at: FieldValue.serverTimestamp(), by, body });
  return { body, cached: false };
}

function rows(body: unknown): Rec[] {
  if (Array.isArray(body)) return body.filter(isRec);
  if (isRec(body) && Array.isArray(body.data)) return body.data.filter(isRec);
  return [];
}

function meta(body: unknown): { last_page?: number; total?: number; per_page?: number } {
  if (!isRec(body)) return {};
  const m = isRec(body.meta) ? body.meta : body;
  return { last_page: Number(m.last_page ?? 1), total: Number(m.total ?? rows(body).length), per_page: Number(m.per_page ?? 100) };
}

// ─── Storage helpers ─────────────────────────────────────────────

async function storeWines(db: Db, list: Rec[], extra: Rec = {}) {
  for (let i = 0; i < list.length; i += 400) {
    const batch = db.batch();
    for (const w of list.slice(i, i + 400)) {
      if (w.id === undefined) continue;
      batch.set(db.collection("grapeminds_wines").doc(String(w.id)), { ...w, ...extra, listedAt: FieldValue.serverTimestamp() }, { merge: true });
    }
    await batch.commit();
  }
}

// ─── Actions: estimate + run ─────────────────────────────────────

export type Action =
  | { type: "ping" }
  | { type: "coverage"; country?: string }
  | { type: "regions"; country?: string }
  | { type: "producers"; country?: string }
  | { type: "wines"; region_id?: string; producer_id?: string; color?: string }
  | { type: "search"; q: string }
  | { type: "details"; ids: string[] }
  | { type: "producer-insights"; id: string }
  | { type: "region-insights"; id: string }
  | { type: "licence"; id: string };

export async function estimate(db: Db, a: Action) {
  const l = await ledger(db);
  const left = Math.max(0, l.budget - l.used);
  let calls = 1;
  let note = "";
  switch (a.type) {
    case "ping": case "coverage": case "regions": case "search": case "producer-insights": case "region-insights": calls = 1; break;
    case "producers": calls = 1; note = "1 call per 100 producers; more pages are fetched automatically if the first page says so"; break;
    case "wines": {
      // Use cached coverage / region info to estimate pages
      const cov = await db.collection("grapeminds_cache").where("url", "==", `${BASE}/coverage?country=${(a as { country?: string }).country ?? "IN"}&lang=en`).limit(1).get();
      note = "1 call per 100 wines. Exact number known after the first page.";
      if (!cov.empty && a.region_id === undefined && a.producer_id === undefined) {
        const total = Number(isRec(cov.docs[0].get("body")) ? (cov.docs[0].get("body") as Rec).wines ?? 0 : 0);
        calls = Math.max(1, Math.ceil(total / 100));
      }
      break;
    }
    case "details": {
      const ids = [...new Set(a.ids)];
      const have = await Promise.all(ids.map((id) => db.collection("grapeminds_wines").doc(id).get()));
      const missing = ids.filter((_, i) => !have[i].exists || !have[i].get("detailAt"));
      calls = missing.length;
      note = `${ids.length - missing.length} already downloaded, ${missing.length} to fetch`;
      break;
    }
    case "licence": calls = 1; note = "GrapeMinds bills a per-wine licence (~€0.38) on paid plans"; break;
  }
  return { calls, left, afterwards: left - calls, allowed: calls <= left, note, month: l.month, used: l.used, budget: l.budget, limit: l.limit };
}

export async function run(db: Db, by: string, a: Action) {
  const est = await estimate(db, a);
  if (!est.allowed) throw new GmError(429, `Not enough calls left this month (${est.left}); this needs ${est.calls}`);
  const out: Rec = { action: a, estimate: est };
  switch (a.type) {
    case "ping": {
      const r = await gmFetch(db, by, "/ping", {}, "en", true);
      out.result = r.body;
      break;
    }
    case "coverage": {
      const r = await gmFetch(db, by, "/coverage", { country: a.country ?? "IN", lang: "en" });
      out.result = r.body;
      await db.collection(LEDGER[0]).doc(LEDGER[1]).set({ coverage: { [a.country ?? "IN"]: r.body, at: FieldValue.serverTimestamp() } }, { merge: true });
      break;
    }
    case "regions": {
      const r = await gmFetch(db, by, "/regions", { country: a.country ?? "IN", per_page: 100 });
      const list = rows(r.body);
      const batch = db.batch();
      for (const x of list) if (x.id !== undefined) batch.set(db.collection("grapeminds_regions").doc(String(x.id)), { ...x, at: FieldValue.serverTimestamp() }, { merge: true });
      await batch.commit();
      out.result = { count: list.length, regions: list };
      break;
    }
    case "producers": {
      const all: Rec[] = [];
      let page = 1;
      for (;;) {
        const r = await gmFetch(db, by, "/producers", { country: a.country ?? "IN", per_page: 100, page });
        all.push(...rows(r.body));
        const m = meta(r.body);
        if (!m.last_page || page >= m.last_page || page >= 5) break;
        page++;
      }
      const batch = db.batch();
      for (const x of all) if (x.id !== undefined) batch.set(db.collection("grapeminds_producers").doc(String(x.id)), { ...x, country: a.country ?? "IN", at: FieldValue.serverTimestamp() }, { merge: true });
      await batch.commit();
      out.result = { count: all.length };
      break;
    }
    case "wines": {
      const all: Rec[] = [];
      let page = 1;
      let pages = 1;
      for (;;) {
        const r = await gmFetch(db, by, "/wines", { region_id: a.region_id, producer_id: a.producer_id, color: a.color, per_page: 100, page });
        all.push(...rows(r.body));
        const m = meta(r.body);
        pages = m.last_page ?? 1;
        if (page >= pages || page >= 10) break;
        const l = await ledger(db);
        if (l.used >= l.budget) break;
        page++;
      }
      await storeWines(db, all, { source: a.region_id ? `region:${a.region_id}` : a.producer_id ? `producer:${a.producer_id}` : "list" });
      out.result = { count: all.length, pages, fetchedPages: page };
      break;
    }
    case "search": {
      const r = await gmFetch(db, by, "/wines/search", { q: a.q, limit: 100 });
      const list = rows(r.body);
      await storeWines(db, list, { source: `search:${a.q}` });
      out.result = { count: list.length, wines: list };
      break;
    }
    case "details": {
      const ids = [...new Set(a.ids)];
      const done: string[] = [];
      for (const id of ids) {
        const have = await db.collection("grapeminds_wines").doc(id).get();
        if (have.exists && have.get("detailAt")) continue;
        const r = await gmFetch(db, by, `/wines/${id}`, {}, "en");
        if (isRec(r.body)) {
          await db.collection("grapeminds_wines").doc(id).set({ ...r.body, detailAt: FieldValue.serverTimestamp() }, { merge: true });
          done.push(id);
        }
      }
      out.result = { fetched: done.length, ids: done };
      break;
    }
    case "producer-insights": case "region-insights": {
      const kind = a.type === "producer-insights" ? "producer" : "region";
      const r = await gmFetch(db, by, `/${a.type}/${a.id}`, { lang: "en" });
      await db.collection("grapeminds_insights").doc(`${kind}_${a.id}`).set({ kind, id: a.id, ...(isRec(r.body) ? r.body : { body: r.body }), at: FieldValue.serverTimestamp() }, { merge: true });
      out.result = r.body;
      break;
    }
    case "licence": {
      const url = `${BASE}/licence/${a.id}`;
      const res = await fetch(url, { method: "POST", headers: { Authorization: `Bearer ${GRAPEMINDS_KEY.value()}`, Accept: "application/json" } });
      const text = await res.text();
      await spend(db, by, url, res.status);
      let body: unknown;
      try { body = JSON.parse(text); } catch { body = { raw: text }; }
      if (!res.ok) throw new GmError(502, `licence failed: ${res.status}`, body);
      await db.collection("grapeminds_wines").doc(a.id).set({ licensed: true, licensedAt: FieldValue.serverTimestamp(), licensedBy: by, licence: body }, { merge: true });
      out.result = body;
      break;
    }
  }
  out.ledger = await ledger(db);
  return out;
}

// ─── Status, listing, matching, mapping ─────────────────────────

export async function status(db: Db) {
  const l = await ledger(db);
  const count = async (q: FirebaseFirestore.Query) => (await q.count().get()).data().count;
  const [wines, withDetail, producers, regions, insights, licensed, mapped] = await Promise.all([
    count(db.collection("grapeminds_wines")),
    count(db.collection("grapeminds_wines").where("detailAt", ">", new Date(0))),
    count(db.collection("grapeminds_producers")),
    count(db.collection("grapeminds_regions")),
    count(db.collection("grapeminds_insights")),
    count(db.collection("grapeminds_wines").where("licensed", "==", true)),
    count(db.collection("products").where("openData.grapeminds.id", ">", 0)),
  ]);
  const doc = await db.collection(LEDGER[0]).doc(LEDGER[1]).get();
  const log = (doc.get("log") as Rec[] | undefined) ?? [];
  return { ...l, ref: undefined, counts: { wines, withDetail, producers, regions, insights, licensed, mappedProducts: mapped }, coverage: doc.get("coverage") ?? null, recent: log.slice(-20).reverse() };
}

export async function setTerms(db: Db, by: string, body: Rec) {
  const terms = { commercialOk: body.commercialOk === true, note: typeof body.note === "string" ? body.note.slice(0, 1000) : "", setBy: by, setAt: FieldValue.serverTimestamp() };
  await db.collection(LEDGER[0]).doc(LEDGER[1]).set({ terms }, { merge: true });
  return { terms: { ...terms, setAt: new Date().toISOString() } };
}

export async function setBudget(db: Db, body: Rec) {
  const b = Math.min(MONTHLY_LIMIT, Math.max(0, Number(body.budget)));
  if (!Number.isFinite(b)) throw new GmError(422, "budget must be a number");
  await db.collection(LEDGER[0]).doc(LEDGER[1]).set({ budget: b }, { merge: true });
  return { budget: b };
}

export async function listWines(db: Db) {
  const snap = await db.collection("grapeminds_wines").get();
  return snap.docs.map((d) => {
    const w = d.data();
    return {
      id: d.id, lwin: w.lwin ?? null, name: w.display_name ?? w.name ?? d.id, color: w.color ?? null, type: w.type ?? null, sub_type: w.sub_type ?? null,
      producer: isRec(w.producer) ? w.producer.name ?? w.producer.display_name : w.producer_name ?? null,
      region: isRec(w.region) ? w.region.name : null, country: isRec(w.region) ? w.region.country : null,
      hasDetail: !!w.detailAt, licensed: w.licensed === true, grapes: w.grapes ?? null, flavor_profile: w.flavor_profile ?? null, source: w.source ?? null,
    };
  });
}

const norm = (s: unknown) => String(s ?? "").toLowerCase().replace(/[^a-z0-9 ]+/g, " ").replace(/\s+/g, " ").trim();
const STOP = new Set(["wine", "wines", "the", "and", "red", "white", "rose", "ros", "brut", "dry", "india", "indian", "reserve", "estate", "vineyards", "vineyard"]);
const tokens = (s: unknown) => new Set(norm(s).split(" ").filter((w) => w.length > 2 && !STOP.has(w)));

/** For each of our wines, the best GrapeMinds candidates from the cached rows. */
export async function matches(db: Db) {
  const [ours, gm] = await Promise.all([db.collection("products").get(), listWines(db)]);
  const wines = ours.docs.map((d) => d.data()).filter((p) => /wine/i.test(String(p.category)) && p.archived !== true);
  return wines.map((p) => {
    const t = tokens(`${p.name} ${p.grapeVariety ?? ""} ${p.subcategory ?? ""}`);
    const scored = gm.map((g) => {
      const gt = tokens(`${g.producer ?? ""} ${g.name}`);
      let hit = 0;
      for (const w of t) if (gt.has(w)) hit++;
      const score = t.size ? hit / t.size : 0;
      return { ...g, score: Math.round(score * 100) / 100 };
    }).filter((g) => g.score > 0).sort((a, b) => b.score - a.score).slice(0, 5);
    const current = isRec(p.openData) && isRec((p.openData as Rec).grapeminds) ? ((p.openData as Rec).grapeminds as Rec) : null;
    return { productId: p.id, name: p.name, category: p.category, region: p.region, grapeVariety: p.grapeVariety ?? null, mapped: current ? { id: current.id, lwin: current.lwin, licensed: current.licensed === true } : null, candidates: scored };
  });
}

/** Which of our fields GrapeMinds would fill or contradict, before the admin applies. */
function buildOpenData(gm: Rec, retrievedBy: string) {
  const fp = isRec(gm.flavor_profile) ? gm.flavor_profile : null;
  return {
    id: gm.id, lwin: gm.lwin ?? null, displayName: gm.display_name ?? null, color: gm.color ?? null, type: gm.type ?? null, subType: gm.sub_type ?? null,
    residualSugar: gm.residual_sugar ?? null,
    producer: isRec(gm.producer) ? { id: gm.producer.id, name: gm.producer.name ?? gm.producer.display_name } : null,
    region: isRec(gm.region) ? { id: gm.region.id, name: gm.region.name, country: gm.region.country } : null,
    grapes: gm.grapes ?? null,
    profile: fp,
    generated: { description: gm.description ?? null, tastingNotes: gm.tasting_notes ?? null, pairing: gm.pairing ?? null, note: "Text generated on demand by GrapeMinds; not a sourced fact" },
    licensed: gm.licensed === true,
    retrievedAt: new Date().toISOString(), retrievedBy, source: "GrapeMinds Wine API", url: "https://grapeminds.eu/",
  };
}

/** Writes a draft of our product with openData.grapeminds (and optional field fills). */
export async function applyMapping(db: Db, by: string, body: Rec) {
  const productId = String(body.productId ?? "");
  const gmId = String(body.gmId ?? "");
  if (!productId || !gmId) throw new GmError(422, "productId and gmId are required");
  const gmSnap = await db.collection("grapeminds_wines").doc(gmId).get();
  if (!gmSnap.exists) throw new GmError(404, "GrapeMinds wine not downloaded yet");
  const gm = gmSnap.data() as Rec;
  const liveSnap = await db.collection("products").doc(productId).get();
  const draftSnap = await db.collection("drafts_products").doc(productId).get();
  const base = (draftSnap.exists ? draftSnap.data() : liveSnap.data()) as Rec | undefined;
  if (!base) throw new GmError(404, "product not found");
  const { _draft, ...current } = base;
  void _draft;
  const openData = isRec(current.openData) ? { ...current.openData } : {};
  openData.grapeminds = buildOpenData(gm, by);
  const next: DocumentData = { ...current, openData };
  const fills: string[] = [];
  const grapes = Array.isArray(gm.grapes) ? gm.grapes.map((g) => (isRec(g) ? g.name ?? g.display_name ?? "" : String(g))).filter(Boolean) : [];
  if (body.fillEmpty !== false) {
    if (!current.grapeVariety && grapes.length) { next.grapeVariety = grapes.join(", "); fills.push("grapeVariety"); }
    if (!current.region && isRec(gm.region) && gm.region.name) { next.region = String(gm.region.name); fills.push("region"); }
    if (!current.subcategory && gm.sub_type) { next.subcategory = String(gm.sub_type); fills.push("subcategory"); }
  }
  const fp = isRec(gm.flavor_profile) ? gm.flavor_profile : null;
  if (body.adoptScores === true && fp) {
    const map: Record<string, string> = { acidity: "acidity", tannins: "tannin", body: "body" };
    for (const [from, to] of Object.entries(map)) {
      if (typeof fp[from] === "number") { next[to] = Math.max(0, Math.min(10, Number(fp[from]))); fills.push(to); }
    }
    next.estimate = { ...(isRec(current.estimate) ? current.estimate : {}), label: "Acidity, tannin and body from GrapeMinds; other scores estimated", source: "grapeminds+estimate", reviewedBy: by, reviewedAt: new Date().toISOString() };
  }
  await db.collection("drafts_products").doc(productId).set({
    ...next, id: productId,
    _draft: { kind: "products", id: productId, savedBy: by, savedAt: FieldValue.serverTimestamp(), baseUpdatedAt: liveSnap.get("updatedAt") ?? null, isNew: !liveSnap.exists, via: "grapeminds" },
  });
  return { productId, gmId, fills, draft: true };
}

/** Creates a new draft drink from a GrapeMinds row (for wines we do not have). */
export async function createFromGrapeminds(db: Db, by: string, body: Rec) {
  const gmId = String(body.gmId ?? "");
  const gmSnap = await db.collection("grapeminds_wines").doc(gmId).get();
  if (!gmSnap.exists) throw new GmError(404, "GrapeMinds wine not downloaded yet");
  const gm = gmSnap.data() as Rec;
  const name = String(body.name ?? gm.display_name ?? "").trim();
  const id = String(body.id ?? "").trim() || name.toLowerCase().normalize("NFKD").replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
  if (!id || !name) throw new GmError(422, "name and id are required");
  const exists = await db.collection("products").doc(id).get();
  if (exists.exists) throw new GmError(409, `${id} already exists`);
  const color = String(gm.color ?? "").toLowerCase();
  const type = String(gm.type ?? gm.sub_type ?? "").toLowerCase();
  const category = /spark|champ|cava|prosecco/.test(type) ? "sparklingWine" : /dessert|sweet|port|fortified/.test(type) ? "dessertWine" : color.startsWith("ros") ? "roseWine" : color === "white" ? "whiteWine" : "redWine";
  const fp = isRec(gm.flavor_profile) ? gm.flavor_profile : {};
  const grapes = Array.isArray(gm.grapes) ? gm.grapes.map((g) => (isRec(g) ? g.name ?? g.display_name ?? "" : String(g))).filter(Boolean) : [];
  const n = (k: string, d: number) => (typeof fp[k] === "number" ? Math.max(0, Math.min(10, Number(fp[k]))) : d);
  const draft: DocumentData = {
    id, name, category, subcategory: String(gm.sub_type ?? ""), region: isRec(gm.region) ? String(gm.region.name ?? "") : "", origin: isRec(gm.region) ? String(gm.region.country ?? "") : "",
    grapeVariety: grapes.join(", "), price: 0, fruit: 5, acidity: n("acidity", 5), body: n("body", 5), tannin: n("tannins", color === "red" ? 5 : 2), freshness: 5, complexity: 5,
    archetypeTags: [], tastingNotes: "", aromas: [], verified: false, sortOrder: 1000, source: "grapeminds", provenance: "grapeminds-import",
    estimate: { label: fp && Object.keys(fp).length ? "Acidity, tannin and body from GrapeMinds; other scores estimated" : "Estimated from published facts", confidence: "low", source: "grapeminds+estimate" },
    openData: { grapeminds: buildOpenData(gm, by) },
  };
  await db.collection("drafts_products").doc(id).set({ ...draft, _draft: { kind: "products", id, savedBy: by, savedAt: FieldValue.serverTimestamp(), baseUpdatedAt: null, isNew: true, via: "grapeminds" } });
  return { id, draft: true };
}

/** Publish gate: GrapeMinds-derived content needs a licence or recorded terms. */
export async function assertPublishable(db: Db, kind: string, doc: Rec) {
  if (kind !== "products") return;
  const gm = isRec(doc.openData) && isRec((doc.openData as Rec).grapeminds) ? ((doc.openData as Rec).grapeminds as Rec) : null;
  if (!gm) return;
  if (gm.licensed === true) return;
  const l = await ledger(db);
  if (l.terms.commercialOk === true) return;
  throw new GmError(422, `${String(doc.id)}: GrapeMinds data is not licensed for publication yet (licence the wine or record GrapeMinds' written confirmation under Data Cellar → GrapeMinds → Terms)`);
}

/** Counts for the Data Cellar cards. */
export async function sourcesOverview(db: Db) {
  const [p, d, gmLedger] = await Promise.all([db.collection("products").get(), db.collection("dishes").get(), ledger(db)]);
  const prods = p.docs.map((x) => x.data());
  const has = (x: Rec, k: string) => isRec(x.openData) && isRec((x.openData as Rec)[k]) && Object.keys((x.openData as Rec)[k] as Rec).length > 0;
  const cnt = (k: string) => prods.filter((x) => has(x, k)).length;
  return {
    sources: [
      { id: "grapeminds", name: "GrapeMinds", kind: "api", status: "connected", provides: "Wine identity (LWIN), grapes, flavour profile, producer and region facts; generated notes and pairings", licence: "Free plan for evaluation; per-wine licence (~€0.38) to store; commercial use on Startup plan", records: cnt("grapeminds"), extra: `${gmLedger.used}/${gmLedger.budget} calls used in ${gmLedger.month}` },
      { id: "openFoodFacts", name: "Open Food Facts", kind: "open-data", status: "linked", provides: "Product facts, ABV, photos", licence: "ODbL; photos CC BY-SA 3.0 (credited)", records: cnt("openFoodFacts") },
      { id: "wikidata", name: "Wikidata", kind: "open-data", status: "linked", provides: "Producer, brand, founding year, country", licence: "CC0", records: cnt("wikidata") },
      { id: "bottlePhoto", name: "Wikimedia Commons", kind: "open-data", status: "linked", provides: "Bottle photos with per-file licence", licence: "Per file (credited)", records: cnt("bottlePhoto") },
      { id: "xwines", name: "X-Wines", kind: "open-data", status: "linked", provides: "Wine ABV, body, pairs-with", licence: "CC0", records: cnt("xwines") },
      { id: "bjcpStyle", name: "BJCP styles", kind: "open-data", status: "linked", provides: "Beer style ABV/IBU ranges", licence: "MIT", records: cnt("bjcpStyle") },
      { id: "indianFood101", name: "Indian Food 101", kind: "open-data", status: "linked", provides: "Dish ingredients, diet, region", licence: "CC0", records: d.docs.filter((x) => has(x.data(), "indianFood101")).length },
      { id: "spiritsdatabase", name: "Spirits Database", kind: "api", status: "unusable", provides: "Spirits catalogue", licence: "Terms allow personal, non-commercial use only", records: 0 },
    ],
    totals: { products: prods.length, dishes: d.size },
  };
}
