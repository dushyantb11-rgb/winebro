/**
 * Pilot stage 6: writes tool/pilot/publish.json into Firestore `products`.
 * - New drinks become catalogue rows (sortOrder 1000+).
 * - Existing drinks get the estimated profile and notes; their old
 *   hand-set profile is kept once in `previousHandAuthored`.
 * - Drinks already `verified` by a sommelier are never overwritten.
 *
 * Usage (from app/functions): node scripts/publish-pilot.js [--write]
 */
const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

const write = process.argv.includes("--write");
const rows = JSON.parse(
  fs.readFileSync(path.join(__dirname, "..", "..", "tool", "pilot", "publish.json"), "utf8")
);

(async () => {
  admin.initializeApp({ projectId: "winebro" });
  const db = admin.firestore();
  let created = 0, updated = 0, skipped = 0;
  const batch = db.batch();
  for (const { id, previousHandAuthored, ...row } of rows) {
    const ref = db.collection("products").doc(id);
    const snap = await ref.get();
    if (snap.exists && snap.get("verified") === true) {
      skipped++;
      continue;
    }
    const data = { ...row, id, updatedAt: admin.firestore.FieldValue.serverTimestamp() };
    if (snap.exists && previousHandAuthored && !snap.get("previousHandAuthored")) {
      data.previousHandAuthored = previousHandAuthored;
    }
    snap.exists ? updated++ : created++;
    if (write) batch.set(ref, data, { merge: true });
  }
  console.log(`new ${created}, updated ${updated}, skipped (verified) ${skipped}`);
  if (!write) return console.log("Dry run. Re-run with --write to publish.");
  await batch.commit();
  const pilot = db.collection("pilot_candidates");
  const b2 = db.batch();
  for (const { id } of rows) b2.set(pilot.doc(id), { publishedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  await b2.commit();
  console.log("published");
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
