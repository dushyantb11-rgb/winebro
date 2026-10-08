/**
 * Pulls Firestore `config/*` into app/tool/config/config.json so the
 * app's bundled fallback can be regenerated from what the admin has
 * published:
 *
 *   node scripts/export-config.js          (from app/functions)
 *   python tool/config/gen_defaults.py     (from app)
 *
 * Metadata fields (version, source, updatedAt) are dropped; the file
 * holds content only.
 */
const path = require("path");
const fs = require("fs");
const admin = require("firebase-admin");

admin.initializeApp({ projectId: "winebro" });
const db = admin.firestore();

const ORDER = [
  "pairingRules", "archetypes", "quiz", "scanner", "gamification", "badges",
  "categories", "occasions", "journalScales", "aromaWheel", "home", "notifications",
];

(async () => {
  const snap = await db.collection("config").get();
  const docs = {};
  for (const d of snap.docs) {
    const { version, source, updatedAt, ...content } = d.data();
    docs[d.id] = content;
    console.log(`${d.id}  v${version ?? "?"}  ${source ?? ""}`);
  }
  const ordered = {};
  for (const id of ORDER) if (docs[id]) ordered[id] = docs[id];
  for (const id of Object.keys(docs)) if (!ordered[id]) ordered[id] = docs[id];

  const file = path.join(__dirname, "..", "..", "tool", "config", "config.json");
  fs.writeFileSync(file, JSON.stringify(ordered, null, 2) + "\n");
  console.log(`wrote ${Object.keys(ordered).length} documents to ${file}`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
