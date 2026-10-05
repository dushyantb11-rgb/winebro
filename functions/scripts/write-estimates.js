/**
 * Writes tool/pilot/ai_estimates.json into Firestore
 * `pilot_candidates/{id}.aiEstimate` and moves status to "estimated"
 * (never back from in_review / approved / rejected).
 *
 * Usage (from app/functions): node scripts/write-estimates.js [--write]
 */
const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

const write = process.argv.includes("--write");
const file = path.join(__dirname, "..", "..", "tool", "pilot", "ai_estimates.json");
const estimates = JSON.parse(fs.readFileSync(file, "utf8"));

(async () => {
  const ids = Object.keys(estimates);
  console.log(`${ids.length} estimates in file`);
  if (!write) return console.log("Dry run. Re-run with --write to store.");
  admin.initializeApp({ projectId: "winebro" });
  const db = admin.firestore();
  const batch = db.batch();
  for (const id of ids) {
    const ref = db.collection("pilot_candidates").doc(id);
    const snap = await ref.get();
    if (!snap.exists) {
      console.warn(`skip ${id}: not in pilot_candidates`);
      continue;
    }
    const keepStatus = ["in_review", "approved", "rejected"].includes(snap.get("status"));
    batch.update(ref, {
      aiEstimate: estimates[id],
      ...(keepStatus ? {} : { status: "estimated" }),
      estimatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
  console.log(`wrote aiEstimate for ${ids.length} drinks`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
