/**
 * CF-04: Account deletion (DPDPA 2023 / GDPR).
 *
 * 1. onCall "deleteAccount" — the user taps Delete account in Settings.
 *    Removes, in order: every subcollection under users/{uid} and the
 *    user document (recursive delete), Storage objects under users/{uid}/,
 *    phone_index rows pointing at the uid, the user's pairing_feedback
 *    rows, then the Firebase Auth user. Returns what was removed.
 *
 * 2. onDocumentDeleted users/{uid} — if the user document is removed by
 *    any other means, the same cleanup runs for the orphaned data.
 */
import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { getStorage } from "firebase-admin/storage";

const BUCKET = "winebro.firebasestorage.app";

export type DeletionReport = {
  userDocuments: boolean;
  storageObjects: number;
  phoneIndexRows: number;
  feedbackRows: number;
  authUser: boolean;
};

async function deleteWhere(collection: string, field: string, value: string): Promise<number> {
  const db = getFirestore();
  let total = 0;
  for (;;) {
    const snap = await db.collection(collection).where(field, "==", value).limit(400).get();
    if (snap.empty) return total;
    const batch = db.batch();
    snap.docs.forEach((d) => batch.delete(d.ref));
    await batch.commit();
    total += snap.size;
    if (snap.size < 400) return total;
  }
}

/** Removes everything that belongs to a user. Safe to run more than once. */
export async function purgeUserData(uid: string, deleteAuthUser: boolean): Promise<DeletionReport> {
  const db = getFirestore();
  const report: DeletionReport = { userDocuments: false, storageObjects: 0, phoneIndexRows: 0, feedbackRows: 0, authUser: false };

  const userRef = db.collection("users").doc(uid);
  await db.recursiveDelete(userRef);
  report.userDocuments = true;

  const [files] = await getStorage().bucket(BUCKET).getFiles({ prefix: `users/${uid}/` });
  await Promise.all(files.map((f) => f.delete({ ignoreNotFound: true })));
  report.storageObjects = files.length;

  report.phoneIndexRows = await deleteWhere("phone_index", "uid", uid);
  report.feedbackRows = await deleteWhere("pairing_feedback", "userId", uid);

  if (deleteAuthUser) {
    try {
      await getAuth().deleteUser(uid);
      report.authUser = true;
    } catch (err) {
      console.warn(`deleteUser(${uid}) failed (may already be gone):`, (err as Error).message);
    }
  }
  return report;
}

export const deleteAccount = onCall(
  { region: "asia-south1", memory: "512MiB", timeoutSeconds: 300 },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Must be signed in to delete the account.");
    const uid = request.auth.uid;
    console.log(`Account deletion: starting for ${uid}`);
    const report = await purgeUserData(uid, true);
    console.log(`Account deletion: done for ${uid}`, JSON.stringify(report));
    return { success: true, ...report };
  },
);

export const userDocCleanup = onDocumentDeleted(
  { document: "users/{uid}", region: "asia-south1", memory: "512MiB", timeoutSeconds: 300 },
  async (event) => {
    const uid = event.params.uid;
    // The document is already gone; recursiveDelete still clears subcollections.
    const report = await purgeUserData(uid, false);
    console.log(`User doc cleanup for ${uid}`, JSON.stringify(report));
  },
);
