/**
 * CF-13: Contact discovery without a public phone index.
 *
 * phone_index/{hmac} → { uid } is written and read only here. The key is
 * HMAC-SHA256(pepper, E.164 number) with a server-side secret, so a
 * leaked document id cannot be turned back into a number offline.
 *
 *   registerPhoneIndex()            — indexes the caller's verified phone
 *   lookupContacts({ phones: [] })  — returns matches for up to 500 numbers
 *                                     (uids only; visibility respected),
 *                                     at most 20 calls per user per hour
 */
import { createHmac } from "crypto";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";

const PEPPER = defineSecret("PHONE_INDEX_PEPPER");
const MAX_PHONES = 500;
const RATE_LIMIT = 20;
const RATE_WINDOW_MS = 60 * 60 * 1000;

/** E.164 normalisation for Indian numbers; null when it is not a usable number. */
export function normalizePhone(raw: string): string | null {
  let s = raw.replace(/[^\d+]/g, "");
  if (!s) return null;
  if (s.startsWith("00")) s = "+" + s.slice(2);
  if (!s.startsWith("+")) {
    if (s.length === 10) s = "+91" + s;
    else if (s.length === 11 && s.startsWith("0")) s = "+91" + s.slice(1);
    else if (s.length === 12 && s.startsWith("91")) s = "+" + s;
    else return null;
  }
  return /^\+[1-9]\d{7,14}$/.test(s) ? s : null;
}

export function phoneKey(pepper: string, e164: string): string {
  return createHmac("sha256", pepper).update(e164).digest("hex");
}

export const registerPhoneIndex = onCall(
  { region: "asia-south1", secrets: [PEPPER], memory: "256MiB" },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign in first.");
    const uid = request.auth.uid;
    const user = await getAuth().getUser(uid);
    const phone = user.phoneNumber ? normalizePhone(user.phoneNumber) : null;
    if (!phone) return { indexed: false, reason: "no verified phone on this account" };
    const key = phoneKey(PEPPER.value(), phone);
    const db = getFirestore();
    const ref = db.collection("phone_index").doc(key);
    await ref.set({ uid, updatedAt: FieldValue.serverTimestamp() });
    await db.collection("users").doc(uid).set({ phoneIndexed: true }, { merge: true });
    return { indexed: true };
  },
);

export const lookupContacts = onCall(
  { region: "asia-south1", secrets: [PEPPER], memory: "256MiB" },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign in first.");
    const uid = request.auth.uid;
    const raw = request.data?.phones;
    if (!Array.isArray(raw)) throw new HttpsError("invalid-argument", "phones must be a list");
    if (raw.length > MAX_PHONES) throw new HttpsError("invalid-argument", `at most ${MAX_PHONES} numbers per call`);

    const db = getFirestore();
    // Rate limit: a small per-user counter document.
    const limitRef = db.collection("users").doc(uid).collection("private").doc("contactLookups");
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(limitRef);
      const now = Date.now();
      const windowStart = snap.exists && snap.get("windowStart") instanceof Timestamp ? (snap.get("windowStart") as Timestamp).toMillis() : 0;
      const inWindow = now - windowStart < RATE_WINDOW_MS;
      const count = inWindow ? Number(snap.get("count") ?? 0) : 0;
      if (count >= RATE_LIMIT) throw new HttpsError("resource-exhausted", "Too many contact lookups; try again later.");
      tx.set(limitRef, { windowStart: inWindow ? Timestamp.fromMillis(windowStart) : Timestamp.fromMillis(now), count: count + 1 });
    });

    const pepper = PEPPER.value();
    const keyToInput = new Map<string, string>();
    for (const p of raw) {
      if (typeof p !== "string") continue;
      const e164 = normalizePhone(p);
      if (e164) keyToInput.set(phoneKey(pepper, e164), p);
    }
    if (keyToInput.size === 0) return { matches: [] };

    const keys = [...keyToInput.keys()];
    const matches: { phone: string; uid: string }[] = [];
    for (let i = 0; i < keys.length; i += 30) {
      const chunk = keys.slice(i, i + 30);
      const snap = await db.collection("phone_index").where("__name__", "in", chunk.map((k) => db.collection("phone_index").doc(k))).get();
      for (const d of snap.docs) {
        const other = String(d.get("uid") ?? "");
        if (!other || other === uid) continue;
        matches.push({ phone: keyToInput.get(d.id) ?? "", uid: other });
      }
    }
    // Respect profile visibility: users who chose "private" are not discoverable.
    const visible: typeof matches = [];
    for (const m of matches) {
      const u = await db.collection("users").doc(m.uid).get();
      if (u.exists && u.get("visibility") !== "private") visible.push(m);
    }
    return { matches: visible };
  },
);
