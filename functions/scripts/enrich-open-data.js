/**
 * Adds facts from open datasets to Firestore `products/{id}.openData`.
 * Our own hand-authored fields are never changed; every value here keeps
 * its source, licence and link so the app can show or cross-check it.
 *
 * Links from our products to each dataset are reviewed by hand in
 * app/tool/open_data/matches.json.
 *
 * Sources and licences:
 *   X-Wines (github.com/rogerioxavier/X-Wines)  CC0 1.0. Cite:
 *     de Azambuja et al., "X-Wines", Big Data Cogn. Comput. 2023, 7(1), 20.
 *   Open Food Facts                              ODbL (data), CC BY-SA 3.0 (photos)
 *   Wikidata                                     CC0 1.0
 *   Wikimedia Commons                            per file, read at import
 *   BJCP 2021 styles via beerjson/bjcp-json      MIT (numeric ranges only)
 *   Indian Food 101 (Kaggle, nehaprabhavalkar)   CC0 1.0
 *
 * Usage (from app/functions, Application Default Credentials):
 *   node scripts/enrich-open-data.js --xwines <XWines_Full_100K_wines.csv>  *     --bjcp <bjcp_styleguide-2021.json> --if101 <indian_food.csv> [--write]
 * Without --write it prints what it would store.
 */
const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

const PROJECT_ID = "winebro";
const UA = "WineBro-open-data/1.0 (theaimindshub@gmail.com)";
const args = process.argv.slice(2);
const write = args.includes("--write");
const argValue = (name) => {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : null;
};
const xwinesPath = argValue("--xwines");
const bjcpPath = argValue("--bjcp");
const if101Path = argValue("--if101");
// --matches <file> (default tool/open_data/matches.json) and
// --collection <name> (default products) let the same import run for
// the data pilot: --matches tool/pilot/open_data_matches.json
// --collection pilot_candidates
const matchesPath =
  argValue("--matches") ??
  path.join(__dirname, "..", "..", "tool", "open_data", "matches.json");
const collection = argValue("--collection") ?? "products";

const matchFile = JSON.parse(fs.readFileSync(matchesPath, "utf8"));
const matches = matchFile.products;
const dishMatches = matchFile.dishes ?? {};
const today = new Date().toISOString().slice(0, 10);

async function getJson(url) {
  for (let attempt = 1; attempt <= 3; attempt++) {
    const res = await fetch(url, {
      headers: { "User-Agent": UA, Accept: "application/json" },
    });
    if (res.ok) return res.json();
    await new Promise((r) => setTimeout(r, 2000 * attempt));
  }
  throw new Error(`GET failed: ${url}`);
}

/** Minimal RFC 4180 CSV parser (quoted fields, doubled quotes). */
function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = "";
  let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (quoted) {
      if (c === '"' && text[i + 1] === '"') { field += '"'; i++; }
      else if (c === '"') quoted = false;
      else field += c;
    } else if (c === '"') quoted = true;
    else if (c === ",") { row.push(field); field = ""; }
    else if (c === "\n" || c === "\r") {
      if (c === "\r" && text[i + 1] === "\n") i++;
      row.push(field); rows.push(row); row = []; field = "";
    } else field += c;
  }
  if (field || row.length) { row.push(field); rows.push(row); }
  const [header, ...body] = rows;
  return body.map((r) => Object.fromEntries(header.map((h, i) => [h, r[i]])));
}

/** X-Wines list fields look like "['Beef', 'Lamb']". */
const pyList = (s) => (s ? [...s.matchAll(/'([^']*)'/g)].map((m) => m[1]) : []);

function loadXWines() {
  const wanted = new Set(
    Object.values(matches).map((m) => m.xwinesId).filter(Boolean).map(String)
  );
  if (wanted.size === 0) return {};
  if (!xwinesPath) throw new Error("--xwines <csv> is required");
  const byId = {};
  for (const r of parseCsv(fs.readFileSync(xwinesPath, "utf8"))) {
    if (wanted.has(r.WineID)) byId[r.WineID] = r;
  }
  return byId;
}

/** BJCP styles by id, numeric ranges only (no guideline text). */
function loadBjcp() {
  const wanted = new Set(
    Object.values(matches).map((m) => m.bjcpStyleId).filter(Boolean)
  );
  if (wanted.size === 0) return {};
  if (!bjcpPath) throw new Error("--bjcp <json> is required");
  const out = {};
  const range = (r) =>
    r ? { min: r.minimum?.value ?? null, max: r.maximum?.value ?? null } : null;
  const walk = (o) => {
    if (Array.isArray(o)) return o.forEach(walk);
    if (!o || typeof o !== "object") return;
    if (o.style_id && wanted.has(o.style_id)) {
      out[o.style_id] = {
        styleId: o.style_id,
        name: o.name,
        abv: range(o.alcohol_by_volume),
        ibu: range(o.international_bitterness_units),
        srm: range(o.color),
      };
    }
    Object.values(o).forEach(walk);
  };
  walk(JSON.parse(fs.readFileSync(bjcpPath, "utf8")));
  return out;
}

function loadIndianFood101() {
  const wanted = new Set(
    Object.values(dishMatches).map((m) => m.indianFood101Name).filter(Boolean)
  );
  if (wanted.size === 0) return {};
  if (!if101Path) throw new Error("--if101 <csv> is required");
  const out = {};
  for (const r of parseCsv(fs.readFileSync(if101Path, "utf8"))) {
    const name = (r.name ?? "").trim();
    if (wanted.has(name)) out[name] = r;
  }
  return out;
}

async function loadWikidata() {
  const qids = new Set();
  for (const m of Object.values(matches)) {
    if (m.wikidataProducer) qids.add(m.wikidataProducer);
    if (m.wikidataProduct) qids.add(m.wikidataProduct);
  }
  const values = [...qids].map((q) => `wd:${q}`).join(" ");
  const sparql = `SELECT ?item ?itemLabel ?website ?inception ?abv ?countryLabel WHERE {
    VALUES ?item { ${values} }
    OPTIONAL { ?item wdt:P856 ?website }
    OPTIONAL { ?item wdt:P571 ?inception }
    OPTIONAL { ?item wdt:P2665 ?abv }
    OPTIONAL { ?item wdt:P17 ?country }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "en". } }`;
  const data = await getJson(
    "https://query.wikidata.org/sparql?format=json&query=" +
      encodeURIComponent(sparql)
  );
  const out = {};
  for (const b of data.results.bindings) {
    const q = b.item.value.split("/").pop();
    const e = (out[q] ??= { qid: q, name: b.itemLabel.value });
    if (b.website && !e.website) e.website = b.website.value;
    if (b.inception && !e.founded) e.founded = Number(b.inception.value.slice(0, 4));
    if (b.abv && e.abv === undefined) e.abv = Number(b.abv.value);
    if (b.countryLabel && !e.country) e.country = b.countryLabel.value;
  }
  return out;
}

async function commonsImage(fileTitle) {
  const data = await getJson(
    "https://commons.wikimedia.org/w/api.php?action=query&prop=imageinfo" +
      "&iiprop=url|extmetadata&iiurlwidth=800&format=json&titles=" +
      encodeURIComponent(`File:${fileTitle}`)
  );
  const page = Object.values(data.query.pages)[0];
  const info = page.imageinfo?.[0];
  if (!info) return null;
  const meta = info.extmetadata ?? {};
  const strip = (s) => (s ?? "").replace(/<[^>]+>/g, "").trim();
  return {
    imageUrl: info.thumburl ?? info.url,
    pageUrl: info.descriptionurl,
    licence: strip(meta.LicenseShortName?.value),
    licenceUrl: meta.LicenseUrl?.value ?? null,
    author: strip(meta.Artist?.value),
    source: "Wikimedia Commons",
    retrievedAt: today,
  };
}

async function openFoodFacts(code) {
  const d = await getJson(
    `https://world.openfoodfacts.org/api/v2/product/${code}` +
      "?fields=product_name,brands,nutriments,image_front_url"
  );
  if (d.status !== 1) return null;
  const p = d.product;
  const alcohol = p.nutriments?.alcohol_100g ?? p.nutriments?.alcohol;
  return {
    barcode: code,
    name: [p.brands, p.product_name].filter(Boolean).join(" · "),
    ...(alcohol !== undefined && alcohol !== "" ? { abv: Number(alcohol) } : {}),
    ...(p.image_front_url
      ? { imageUrl: p.image_front_url, imageLicence: "CC BY-SA 3.0" }
      : {}),
    url: `https://world.openfoodfacts.org/product/${code}`,
    source: "Open Food Facts",
    licence: "ODbL 1.0",
    retrievedAt: today,
  };
}

(async () => {
  const xwines = loadXWines();
  const bjcp = loadBjcp();
  const if101 = loadIndianFood101();
  const wikidata = await loadWikidata();
  const updates = {};

  for (const [id, m] of Object.entries(matches)) {
    const openData = {};

    if (m.xwinesId) {
      const r = xwines[String(m.xwinesId)];
      if (!r) console.warn(`${id}: X-Wines ${m.xwinesId} not in CSV`);
      else openData.xwines = {
        wineId: Number(r.WineID),
        name: `${r.WineryName} ${r.WineName}`,
        abv: Number(r.ABV),
        body: r.Body,
        acidity: r.Acidity,
        grapes: pyList(r.Grapes),
        pairsWith: pyList(r.Harmonize),
        country: r.Country,
        region: r.RegionName,
        source: "X-Wines",
        licence: "CC0 1.0",
        url: "https://github.com/rogerioxavier/X-Wines",
        collected: "2022, open web",
        retrievedAt: today,
      };
    }

    if (m.offBarcode) {
      const off = await openFoodFacts(m.offBarcode);
      if (off) openData.openFoodFacts = off;
      await new Promise((r) => setTimeout(r, 700));
    }

    const wd = {};
    if (m.wikidataProducer && wikidata[m.wikidataProducer]) {
      wd.producer = wikidata[m.wikidataProducer];
    }
    if (m.wikidataProduct && wikidata[m.wikidataProduct]) {
      wd.product = wikidata[m.wikidataProduct];
    }
    if (Object.keys(wd).length) {
      openData.wikidata = {
        ...wd,
        source: "Wikidata",
        licence: "CC0 1.0",
        retrievedAt: today,
      };
    }

    if (m.bjcpStyleId && bjcp[m.bjcpStyleId]) {
      openData.bjcpStyle = {
        ...bjcp[m.bjcpStyleId],
        evidence: "BJCP 2021 lists this beer as a commercial example",
        source: "BJCP 2021 Style Guidelines (beerjson/bjcp-json)",
        licence: "MIT",
        url: "https://github.com/beerjson/bjcp-json",
        retrievedAt: today,
      };
    }

    if (m.commonsBottleImage) {
      const img = await commonsImage(m.commonsBottleImage);
      if (img) openData.bottlePhoto = img;
    }

    if (Object.keys(openData).length) updates[id] = openData;
  }

  // "-1" marks a missing value in Indian Food 101.
  const clean = (v) => (v && v !== "-1" ? v : null);
  const dishUpdates = {};
  for (const [id, m] of Object.entries(dishMatches)) {
    const r = m.indianFood101Name && if101[m.indianFood101Name];
    if (!r) continue;
    dishUpdates[id] = {
      indianFood101: {
        name: r.name.trim(),
        ingredients: r.ingredients.split(",").map((s) => s.trim()).filter(Boolean),
        diet: clean(r.diet),
        flavourProfile: clean(r.flavor_profile),
        course: clean(r.course),
        state: clean(r.state),
        region: clean(r.region),
        source: "Indian Food 101 (Kaggle)",
        licence: "CC0 1.0",
        url: "https://www.kaggle.com/datasets/nehaprabhavalkar/indian-food-101",
        note: "Community dataset; flavour labels are coarse",
        retrievedAt: today,
      },
    };
  }

  const count = (k) => Object.values(updates).filter((u) => u[k]).length;
  console.log(
    `products with open data: ${Object.keys(updates).length}/${Object.keys(matches).length}` +
      ` | X-Wines ${count("xwines")} | Open Food Facts ${count("openFoodFacts")}` +
      ` | Wikidata ${count("wikidata")} | bottle photo ${count("bottlePhoto")}` +
      ` | BJCP style ${count("bjcpStyle")}` +
      `
dishes with open data: ${Object.keys(dishUpdates).length}/${Object.keys(dishMatches).length}`
  );

  if (!write) {
    const [firstId, first] = Object.entries(updates)[0] ?? [];
    if (firstId) console.log(`sample ${firstId}:`, JSON.stringify(first, null, 1));
    console.log("Dry run. Re-run with --write to store.");
    return;
  }

  admin.initializeApp({ projectId: PROJECT_ID });
  const db = admin.firestore();
  const batch = db.batch();
  const stamp = admin.firestore.FieldValue.serverTimestamp();
  for (const [id, openData] of Object.entries(updates)) {
    batch.update(db.collection(collection).doc(id), {
      openData,
      openDataUpdatedAt: stamp,
    });
  }
  for (const [id, openData] of Object.entries(dishUpdates)) {
    batch.update(db.collection("dishes").doc(id), {
      openData,
      openDataUpdatedAt: stamp,
    });
  }
  await batch.commit();
  console.log(
    `wrote openData to ${Object.keys(updates).length} products and ` +
      `${Object.keys(dishUpdates).length} dishes`
  );
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
