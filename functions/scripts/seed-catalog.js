/**
 * Uploads the drink and dish catalogue to Firestore `products` and
 * `dishes`. Source file: app/tool/catalog/catalog.json, produced by
 * `flutter test tool/catalog/export_catalog_test.dart`.
 *
 * Every document carries provenance so the app and reviewers can tell
 * hand-authored seed rows from verified or feed-sourced ones:
 *   source      "winebro-seed"
 *   provenance  "hand-authored"
 *   verified    false
 *   seedVersion integer, bump when the seed content changes
 *
 * Usage (from app/functions, with Application Default Credentials):
 *   node scripts/seed-catalog.js            dry run, prints counts
 *   node scripts/seed-catalog.js --write    writes to project winebro
 *
 * Rows are upserted by id (merge, so `openData` from enrich-open-data.js
 * survives a re-seed). Rows in Firestore that are not in the file are
 * left alone and listed, never deleted.
 */
const path = require("path");
const fs = require("fs");
const admin = require("firebase-admin");

const SEED_VERSION = 1;
const PROJECT_ID = "winebro";
const write = process.argv.includes("--write");

const file = path.join(__dirname, "..", "..", "tool", "catalog", "catalog.json");
const catalog = JSON.parse(fs.readFileSync(file, "utf8"));

admin.initializeApp({ projectId: PROJECT_ID });
const db = admin.firestore();

async function upload(collection, rows) {
  const existing = await db.collection(collection).select().get();
  const fileIds = new Set(rows.map((r) => r.id));
  const extra = existing.docs.map((d) => d.id).filter((id) => !fileIds.has(id));

  console.log(`${collection}: ${rows.length} in file, ${existing.size} in Firestore`);
  if (extra.length) console.log(`  not in file (left untouched): ${extra.join(", ")}`);
  if (!write) return;

  for (let i = 0; i < rows.length; i += 400) {
    const batch = db.batch();
    for (const row of rows.slice(i, i + 400)) {
      batch.set(db.collection(collection).doc(row.id), {
        ...row,
        source: "winebro-seed",
        provenance: "hand-authored",
        verified: false,
        seedVersion: SEED_VERSION,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true }); // keep openData written by enrich-open-data.js
    }
    await batch.commit();
  }
  console.log(`  wrote ${rows.length}`);
}

(async () => {
  await upload("products", catalog.products);
  await upload("dishes", catalog.dishes);
  if (!write) console.log("Dry run. Re-run with --write to upload.");
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
