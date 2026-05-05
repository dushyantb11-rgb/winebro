/**
 * CF-09: "Did Bro get it right?" — 24h Pairing Feedback Push
 *
 * Scheduled hourly. For each users/{uid}/journal/{entryId} document
 * with `foodPaired` set, age 24-25h, and no `feedbackRequestedAt`
 * yet, send a targeted push prompting Yes/Maybe/No feedback. Tap
 * deep-links to /feedback/{entryId} which opens the response sheet.
 *
 * This is the D6 data asset (Pairing Success Rate) starting to
 * collect — the gold mine called out in DATA-STRATEGY. Every Yes/No
 * tunes the next user's pairing recommendation in S2.3 engine v1.1.
 *
 * One write per entry: `feedbackRequestedAt` flag is set BEFORE the
 * push send so a re-run within the next hour never duplicates.
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

const FEEDBACK_AGE_MIN_HOURS = 24;
const FEEDBACK_AGE_MAX_HOURS = 25;

export const pairingFeedback24h = onSchedule(
  {
    schedule: "0 * * * *", // every hour on the hour
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
  },
  async () => {
    const firestore = getFirestore();
    const messaging = getMessaging();

    const now = Date.now();
    const minCreated = new Date(
      now - FEEDBACK_AGE_MAX_HOURS * 60 * 60 * 1000
    ).toISOString();
    const maxCreated = new Date(
      now - FEEDBACK_AGE_MIN_HOURS * 60 * 60 * 1000
    ).toISOString();

    // collectionGroup query — needs composite index on
    // (foodPaired, createdAt) over the `journal` collection group.
    const snap = await firestore
      .collectionGroup("journal")
      .where("createdAt", ">=", minCreated)
      .where("createdAt", "<", maxCreated)
      .get();

    let sent = 0;
    let skipped = 0;
    let errors = 0;

    for (const doc of snap.docs) {
      const data = doc.data();

      if (!data.foodPaired) {
        skipped++;
        continue;
      }
      if (data.feedbackRequestedAt) {
        skipped++;
        continue;
      }

      const uid = doc.ref.parent.parent?.id;
      if (!uid) {
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
      const foodPaired = data.foodPaired as string;

      try {
        await doc.ref.update({
          feedbackRequestedAt: FieldValue.serverTimestamp(),
        });

        await messaging.send({
          token,
          notification: {
            title: "Did Bro get it right?",
            body: `Yesterday's ${productName} with ${foodPaired} — how did it land?`,
          },
          data: {
            type: "pairingFeedback",
            entryId: doc.id,
            productId: (data.productId as string) ?? "",
            productName,
            foodPaired,
          },
          android: {
            priority: "high",
            notification: {
              channelId: "pairing_feedback",
              tag: `pairingFeedback_${doc.id}`,
            },
          },
          apns: {
            payload: { aps: { sound: "default", badge: 1 } },
          },
        });
        sent++;
      } catch (err) {
        errors++;
        console.error(`pairingFeedback24h send failed entry=${doc.id}:`, err);
      }
    }

    console.log(
      `pairingFeedback24h: sent=${sent} skipped=${skipped} errors=${errors}`
    );
  }
);
