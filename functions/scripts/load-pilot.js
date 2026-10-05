/**
 * Loads the data pilot list (app/tool/pilot/pilot_list.json) into
 * Firestore `pilot_candidates/{id}` with status "selected". The app does
 * not read this collection; approved rows are copied to `products` later.
 *
 * Usage (from app/functions, Application Default Credentials):
 *   node scripts/load-pilot.js           dry run
 *   node scripts/load-pilot.js --write   writes to project winebro
 *
 * Merges by id, so later stages (facts, aiDraft, review) are kept.
 */
const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

const write = process.argv.includes("--write");
const list = JSON.parse(
  fs.readFileSync(
    path.join(__dirname, "..", "..", "tool", "pilot", "pilot_list.json"),
    "utf8"
  )
);

(async () => {
  const drinks = list.drinks;
  const matched = drinks.filter((d) => d.ksbcl).length;
  console.log(
    `${drinks.length} drinks (${drinks.filter((d) => d.inCatalog).length} in catalogue, ` +
      `${matched} with an official KSBCL match)`
  );
  if (!write) {
    console.log("Dry run. Re-run with --write to store.");
    return;
  }
  admin.initializeApp({ projectId: "winebro" });
  const db = admin.firestore();
  const batch = db.batch();
  for (const d of drinks) {
    const ref = db.collection("pilot_candidates").doc(d.id);
    const snap = await ref.get();
    batch.set(
      ref,
      {
        ...d,
        ...(snap.exists ? {} : { status: "selected" }),
        selectedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }
  await batch.commit();
  console.log(`wrote ${drinks.length} pilot_candidates`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
