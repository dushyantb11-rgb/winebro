/**
 * Uploads the app's rule sets and reference lists to Firestore
 * `config/{doc}`. Source file: app/tool/config/config.json, produced by
 * `flutter test tool/config/export_config_test.dart`.
 *
 * Each document gets:
 *   version    integer, +1 on every write that changes content
 *   source     "code-export" (this script) or "admin" (admin web app)
 *   updatedAt  server timestamp
 * The previous content is copied to `config/{doc}/history/{version}`
 * before it is replaced, so an older version can be restored.
 *
 * Usage (from app/functions, with Application Default Credentials):
 *   node scripts/seed-config.js            dry run, prints what would change
 *   node scripts/seed-config.js --write    writes to project winebro
 *   node scripts/seed-config.js --write --only pairingRules,quiz
 */
const path = require("path");
const fs = require("fs");
const admin = require("firebase-admin");

const WRITE = process.argv.includes("--write");
const onlyArg = process.argv.indexOf("--only");
const ONLY = onlyArg > -1 ? process.argv[onlyArg + 1].split(",") : null;

const file = path.join(__dirname, "..", "..", "tool", "config", "config.json");
const config = JSON.parse(fs.readFileSync(file, "utf8"));

admin.initializeApp({ projectId: "winebro" });
const db = admin.firestore();

function stripMeta(data) {
  const { version, source, updatedAt, ...rest } = data || {};
  return rest;
}

function same(a, b) {
  return JSON.stringify(a) === JSON.stringify(b);
}

(async () => {
  let changed = 0;
  for (const [docId, body] of Object.entries(config)) {
    if (ONLY && !ONLY.includes(docId)) continue;
    const ref = db.collection("config").doc(docId);
    const snap = await ref.get();
    const current = snap.exists ? snap.data() : null;
    const currentVersion = current ? current.version || 0 : 0;

    if (current && same(stripMeta(current), body)) {
      console.log(`= ${docId}  unchanged (v${currentVersion})`);
      continue;
    }
    changed++;
    const nextVersion = currentVersion + 1;
    console.log(`${current ? "~" : "+"} ${docId}  v${currentVersion} -> v${nextVersion}`);
    if (!WRITE) continue;

    const batch = db.batch();
    if (current) {
      batch.set(ref.collection("history").doc(String(currentVersion)), {
        ...current,
        archivedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    batch.set(ref, {
      ...body,
      version: nextVersion,
      source: "code-export",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
  console.log(
    `${WRITE ? "Wrote" : "Would write"} ${changed} document(s)` +
      (WRITE ? "" : " (dry run; add --write)"),
  );
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
