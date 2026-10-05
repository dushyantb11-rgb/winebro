/**
 * Exports Firestore `pilot_candidates` to app/tool/pilot/pilot_export.json
 * (facts + openData per drink) so tool/pilot/ai_estimate.py can run
 * offline from the database.
 *
 * Usage (from app/functions): node scripts/export-pilot.js
 */
const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

admin.initializeApp({ projectId: "winebro" });

(async () => {
  const snap = await admin.firestore().collection("pilot_candidates").get();
  const products = await admin.firestore().collection("products").get();
  const ours = Object.fromEntries(products.docs.map((d) => [d.id, d.data()]));
  const out = snap.docs.map((d) => {
    const x = d.data();
    const p = ours[d.id];
    return {
      id: d.id,
      name: x.name,
      category: x.category,
      brand: x.brand ?? null,
      reason: x.reason,
      facts: x.facts ?? {},
      openData: x.openData ?? p?.openData ?? {},
      // Our hand-authored values for catalogue drinks: used only as the
      // app's scale reference, never as evidence.
      catalog: p
        ? {
            subcategory: p.subcategory, region: p.region, abv: p.abv ?? null,
            fruit: p.fruit, acidity: p.acidity, body: p.body,
            tannin: p.tannin, freshness: p.freshness, complexity: p.complexity,
          }
        : null,
    };
  });
  const file = path.join(__dirname, "..", "..", "tool", "pilot", "pilot_export.json");
  fs.writeFileSync(file, JSON.stringify(out, null, 1));
  console.log(`exported ${out.length} drinks to ${file}`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
