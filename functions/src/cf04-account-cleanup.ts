/**
 * CF-04: Account Cleanup
 *
 * Two-part cleanup strategy:
 *
 * 1. onCall "deleteAccount" — callable from the Flutter app.
 *    Deletes all user data, then deletes the Firebase Auth user.
 *    This is the primary path (user taps "Delete Account" in settings).
 *
 * 2. onDocumentDeleted — if the user doc is deleted by any means
 *    (admin action, direct Firestore delete), clean up orphaned subcollections.
 *
 * Required for GDPR and DPDPA 2023 compliance.
 */

import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, WriteBatch } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { BATCH_LIMIT } from "./constants";

/**
 * Delete all documents in a subcollection using batched writes.
 */
async function deleteSubcollection(
  parentPath: string,
  subcollectionName: string
): Promise<number> {
  const db = getFirestore();
  const collRef = db.collection(`${parentPath}/${subcollectionName}`);
  const snapshot = await collRef.get();

  if (snapshot.empty) return 0;

  let batch: WriteBatch = db.batch();
  let count = 0;
  let batchCount = 0;

  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    count++;
    batchCount++;

    if (batchCount >= BATCH_LIMIT) {
      await batch.commit();
      batch = db.batch();
      batchCount = 0;
    }
  }

  if (batchCount > 0) {
    await batch.commit();
  }

  return count;
}

/**
 * Callable function: deleteAccount
 *
 * Called from Flutter when user taps "Delete Account".
 * 1. Deletes all Firestore subcollections (journal, gamification, dailyPick)
 * 2. Deletes the user document
 * 3. Deletes the Firebase Auth user
 */
export const deleteAccount = onCall(
  {
    memory: "256MiB",
  },
  async (request) => {
    // Must be authenticated
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be signed in to delete account."
      );
    }

    const uid = request.auth.uid;
    const db = getFirestore();
    const userPath = `users/${uid}`;

    console.log(`Account deletion: starting for user ${uid}`);

    // Delete all known subcollections
    const subcollections = ["journal", "gamification", "dailyPick"];

    const results = await Promise.all(
      subcollections.map((sub) => deleteSubcollection(userPath, sub))
    );
    const totalDeleted = results.reduce((sum, count) => sum + count, 0) + 1;

    // Delete the user document
    await db.doc(userPath).delete();

    // Delete the Firebase Auth user
    try {
      await getAuth().deleteUser(uid);
      console.log(`  Deleted Auth user ${uid}`);
    } catch (err) {
      console.warn(`  Failed to delete Auth user (may already be deleted):`, err);
    }

    console.log(
      `Account deletion: completed for user ${uid}, ${totalDeleted} documents deleted`
    );

    return { success: true, deletedDocuments: totalDeleted };
  }
);

/**
 * Firestore trigger: clean up orphaned subcollections
 * when a user document is deleted by any means.
 */
export const userDocCleanup = onDocumentDeleted(
  {
    document: "users/{uid}",
    memory: "256MiB",
  },
  async (event) => {
    const uid = event.params.uid;
    const subcollections = ["journal", "gamification", "dailyPick"];

    const results = await Promise.all(
      subcollections.map((sub) => deleteSubcollection(`users/${uid}`, sub))
    );
    const totalDeleted = results.reduce((sum, count) => sum + count, 0);

    console.log(
      `User doc cleanup: deleted ${totalDeleted} orphaned docs for ${uid}`
    );
  }
);
