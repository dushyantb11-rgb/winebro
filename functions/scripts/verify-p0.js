/**
 * End-to-end check of the server-authoritative paths after deploy, using a
 * throwaway user. Run from app/functions with ADC:
 *   node scripts/verify-p0.js
 *
 * 1. events → CF-02 computes gamification state (XP, streak, badge)
 * 2. journal entry + pairing_feedback → CF-12b updates pairing_aggregates
 * 3. deleting users/{uid} → userDocCleanup removes subcollections and feedback
 */
const admin = require("firebase-admin");

admin.initializeApp({ projectId: "winebro" });
const db = admin.firestore();
const UID = "zz-verify-p0-" + Date.now().toString(36);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function waitFor(check, label, tries = 20) {
  for (let i = 0; i < tries; i++) {
    const v = await check();
    if (v) return v;
    await sleep(1500);
  }
  throw new Error(`timed out waiting for ${label}`);
}

(async () => {
  const user = db.collection("users").doc(UID);
  await user.set({ displayName: "Verify P0", createdAt: new Date().toISOString() });

  // 1. gamification via events
  await user.collection("events").add({ type: "scan", category: "redWine", createdAt: admin.firestore.FieldValue.serverTimestamp() });
  let state = await waitFor(async () => {
    const s = await user.collection("gamification").doc("state").get();
    return s.exists ? s.data() : null;
  }, "gamification state");
  console.log("after scan:", { xp: state.xp, streak: state.streak, totalScans: state.totalScans, badges: state.earnedBadgeIds });
  if (state.totalScans !== 1 || !state.earnedBadgeIds.includes("first-scan")) throw new Error("scan event not applied correctly");
  const xpAfterScan = state.xp; // 5 + 50 (Eagle Eye)

  await user.collection("events").add({ type: "journalEntry", category: "redWine", withFoodPairing: true, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  state = await waitFor(async () => {
    const s = await user.collection("gamification").doc("state").get();
    return s.exists && s.data().totalJournalEntries === 1 ? s.data() : null;
  }, "journal event");
  console.log("after journal+pairing:", { xp: state.xp, totalPairings: state.totalPairings, badges: state.earnedBadgeIds });
  if (state.totalPairings !== 1 || state.xp <= xpAfterScan) throw new Error("journal event not applied correctly");

  // 2. feedback → aggregate
  const entryId = "e1";
  await user.collection("journal").doc(entryId).set({ id: entryId, userId: UID, productId: "sula-rasa-shiraz", productName: "Sula Rasa Shiraz", rating: 5, createdAt: new Date().toISOString(), foodPaired: "Butter Chicken" });
  const fbId = `${UID}_${entryId}`;
  await db.collection("pairing_feedback").doc(fbId).set({ id: fbId, userId: UID, entryId, productId: "sula-rasa-shiraz", productName: "Sula Rasa Shiraz", foodPaired: "Butter Chicken", response: "yes", respondedAt: new Date().toISOString() });
  const aggRef = db.collection("pairing_aggregates").doc("sula-rasa-shiraz__butter-chicken");
  const before = (await aggRef.get()).data() || { yes: 0, maybe: 0, no: 0 };
  let agg = await waitFor(async () => {
    const a = await aggRef.get();
    return a.exists && a.data().yes === before.yes + 1 ? a.data() : null;
  }, "aggregate yes+1");
  console.log("aggregate after yes:", { yes: agg.yes, maybe: agg.maybe, no: agg.no });
  await db.collection("pairing_feedback").doc(fbId).set({ id: fbId, userId: UID, entryId, productId: "sula-rasa-shiraz", productName: "Sula Rasa Shiraz", foodPaired: "Butter Chicken", response: "no", respondedAt: new Date().toISOString() });
  agg = await waitFor(async () => {
    const a = await aggRef.get();
    return a.exists && a.data().yes === before.yes && a.data().no === before.no + 1 ? a.data() : null;
  }, "aggregate yes-1 no+1");
  console.log("aggregate after change to no:", { yes: agg.yes, maybe: agg.maybe, no: agg.no });

  // 3. deletion via userDocCleanup
  await user.delete();
  await waitFor(async () => {
    const [j, g, e, f] = await Promise.all([
      user.collection("journal").get(), user.collection("gamification").get(), user.collection("events").get(),
      db.collection("pairing_feedback").where("userId", "==", UID).get(),
    ]);
    return j.empty && g.empty && e.empty && f.empty ? true : null;
  }, "cleanup");
  console.log("cleanup: journal, gamification, events and feedback rows removed");

  // restore the aggregate to what it was (test data must not leak into ranking)
  await aggRef.set({ ...before, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  console.log("OK");
  process.exit(0);
})().catch(async (e) => {
  console.error("FAILED:", e.message);
  try { await db.recursiveDelete(db.collection("users").doc(UID)); } catch { /* ignore */ }
  process.exit(1);
});
