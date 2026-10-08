/**
 * Push helpers shared by the scheduled and triggered functions.
 *
 * Tokens live at users/{uid}/fcm_token/{docId} ({ token, platform?,
 * updatedAt }). A send that FCM rejects as "not registered" or
 * "invalid argument" deletes that token document so it is never used
 * again.
 */
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";

export type PushResult = { sent: number; failed: number; removed: number };

const DEAD_TOKEN_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
  "messaging/invalid-argument",
]);

/** Sends one message to every token of a user. Resolves even when all sends fail. */
export async function sendToUser(uid: string, message: Omit<Message, "token" | "topic" | "condition">): Promise<PushResult> {
  const db = getFirestore();
  const snap = await db.collection("users").doc(uid).collection("fcm_token").get();
  const result: PushResult = { sent: 0, failed: 0, removed: 0 };
  const messaging = getMessaging();
  for (const doc of snap.docs) {
    const token = doc.get("token");
    if (typeof token !== "string" || !token) {
      await doc.ref.delete();
      result.removed++;
      continue;
    }
    try {
      await messaging.send({ ...(message as Message), token });
      result.sent++;
    } catch (err) {
      const code = (err as { code?: string }).code ?? "";
      if (DEAD_TOKEN_CODES.has(code)) {
        await doc.ref.delete();
        result.removed++;
      } else {
        result.failed++;
        console.warn(`push to ${uid} failed (${code || "unknown"}):`, (err as Error).message);
      }
    }
  }
  return result;
}

/** True when a user has at least one registered token. */
export async function hasToken(uid: string): Promise<boolean> {
  const snap = await getFirestore().collection("users").doc(uid).collection("fcm_token").limit(1).get();
  return !snap.empty;
}
