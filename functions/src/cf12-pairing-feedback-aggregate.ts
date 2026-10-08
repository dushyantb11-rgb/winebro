/**
 * CF-12: Pairing feedback → aggregate (server-authoritative).
 *
 * Clients may only create/update their own pairing_feedback/{uid}_{entryId}
 * document. This trigger verifies the referenced journal entry belongs to
 * that user and names the same product, then moves the yes/maybe/no
 * counters of pairing_aggregates/{productId}__{dishKey} in a transaction,
 * reversing the previous response when a user changes their mind.
 */
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

type Response = "yes" | "maybe" | "no";
const RESPONSES = new Set<Response>(["yes", "maybe", "no"]);

/** Same normalisation as the app's `_normalizeDishKey`. */
export function dishKey(foodPaired: string): string {
  return foodPaired.trim().toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "") || "unknown";
}

export const pairingFeedbackAggregate = onDocumentWritten(
  { document: "pairing_feedback/{feedbackId}", region: "asia-south1", memory: "256MiB" },
  async (event) => {
    const change = event.data;
    if (!change) return;
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    const doc = after ?? before;
    if (!doc) return;

    const userId = String(doc.userId ?? "");
    const entryId = String(doc.entryId ?? "");
    const productId = String(doc.productId ?? "");
    if (!userId || !entryId || !productId) return;
    if (event.params.feedbackId !== `${userId}_${entryId}`) {
      console.warn(`feedback ${event.params.feedbackId}: id does not match ${userId}_${entryId}; ignored`);
      return;
    }

    const db = getFirestore();
    const entry = await db.collection("users").doc(userId).collection("journal").doc(entryId).get();
    if (!entry.exists || String(entry.get("productId") ?? "") !== productId) {
      console.warn(`feedback ${event.params.feedbackId}: journal entry missing or product mismatch; ignored`);
      return;
    }
    const food = String(entry.get("foodPaired") ?? doc.foodPaired ?? "");
    const key = dishKey(food);
    const aggRef = db.collection("pairing_aggregates").doc(`${productId}__${key}`);

    // Our own marking write (applied: true, same response) → nothing to do.
    if (after && before && after.applied === true && before.applied !== true && before.response === after.response) return;
    const prev = before && RESPONSES.has(before.response) && before.applied === true ? (before.response as Response) : null;
    const next = after && RESPONSES.has(after.response) ? (after.response as Response) : null;
    if (prev === next && after?.applied === true) return;

    await db.runTransaction(async (tx) => {
      const agg = await tx.get(aggRef);
      const counts = { yes: 0, maybe: 0, no: 0, ...(agg.exists ? agg.data() : {}) } as Record<Response, number> & Record<string, unknown>;
      if (prev) counts[prev] = Math.max(0, Number(counts[prev]) - 1);
      if (next) counts[next] = Number(counts[next]) + 1;
      tx.set(aggRef, {
        productId, dishKey: key,
        yes: counts.yes, maybe: counts.maybe, no: counts.no,
        updatedAt: FieldValue.serverTimestamp(),
      });
      if (after && next) tx.update(change.after.ref, { applied: true, dishKey: key, appliedAt: FieldValue.serverTimestamp() });
    });
  },
);
