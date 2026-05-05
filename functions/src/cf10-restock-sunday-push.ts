/**
 * CF-10: Sunday Restock Push
 *
 * Scheduled Sundays 11:00 IST. CollectionGroup query on journal
 * entries with `buyAgain == true`, age 28-35 days. Fires a targeted
 * token push to each user who has a candidate, suggesting they
 * reorder. Tap deep-links to Home where the Restock card surfaces
 * the same record.
 *
 * Generates D7 "Restocking behaviour" data — every reorder vs
 * dismiss writes a signal we use to refine the cycle estimates.
 *
 * Idempotent across week-boundary: we mark
 * `restockNotifiedAt` on the journal doc before sending so a
 * re-run on the same Sunday never duplicates.
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

const RESTOCK_AGE_MIN_DAYS = 28;
const RESTOCK_AGE_MAX_DAYS = 35;

export const restockSundayPush = onSchedule(
  {
    schedule: "0 11 * * 0", // 11:00 IST every Sunday
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
  },
  async () => {
    const firestore = getFirestore();
    const messaging = getMessaging();

    const now = Date.now();
    const minCreated = new Date(
      now - RESTOCK_AGE_MAX_DAYS * 24 * 60 * 60 * 1000
    ).toISOString();
    const maxCreated = new Date(
      now - RESTOCK_AGE_MIN_DAYS * 24 * 60 * 60 * 1000
    ).toISOString();

    // collectionGroup needs a composite index on
    // (buyAgain ASC, createdAt ASC) for `journal`.
    const snap = await firestore
      .collectionGroup("journal")
      .where("buyAgain", "==", true)
      .where("createdAt", ">=", minCreated)
      .where("createdAt", "<", maxCreated)
      .get();

    let sent = 0;
    let skipped = 0;
    let errors = 0;
    const notifiedUids = new Set<string>();

    for (const doc of snap.docs) {
      const data = doc.data();

      // Already notified within current 7-day window? skip.
      if (data.restockNotifiedAt) {
        const notifiedDate = (data.restockNotifiedAt as FirebaseFirestore.Timestamp | null)
          ?.toDate();
        if (
          notifiedDate &&
          now - notifiedDate.getTime() < 7 * 24 * 60 * 60 * 1000
        ) {
          skipped++;
          continue;
        }
      }

      const uid = doc.ref.parent.parent?.id;
      if (!uid) {
        skipped++;
        continue;
      }

      // One push per user per Sunday — even if they have multiple
      // candidates. Take the first (oldest by query order).
      if (notifiedUids.has(uid)) {
        skipped++;
        continue;
      }

      const tokenDoc = await firestore
        .collection("users")
        .doc(uid)
        .collection("fcm_token")
        .doc("primary")
        .get();
      const token = tokenDoc.data()?.token as string | undefined;
      if (!token) {
        skipped++;
        continue;
      }

      const productName = data.productName as string;
      const productId = (data.productId as string) ?? "";

      try {
        await doc.ref.update({
          restockNotifiedAt: FieldValue.serverTimestamp(),
        });

        await messaging.send({
          token,
          notification: {
            title: "Time to restock?",
            body: `You loved ${productName} a few weeks ago. Bro thinks the bottle's running low.`,
          },
          data: {
            type: "restock",
            productId,
            productName,
            entryId: doc.id,
          },
          android: {
            priority: "normal",
            notification: {
              channelId: "restock",
              tag: `restock_${doc.id}`,
            },
          },
          apns: {
            payload: { aps: { sound: "default", badge: 1 } },
          },
        });
        notifiedUids.add(uid);
        sent++;
      } catch (err) {
        errors++;
        console.error(`restockSundayPush send failed entry=${doc.id}:`, err);
      }
    }

    console.log(
      `restockSundayPush: sent=${sent} skipped=${skipped} errors=${errors}`
    );
  }
);
