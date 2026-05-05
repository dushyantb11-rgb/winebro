/**
 * CF-07: Streak Loss Warning Push
 *
 * Scheduled 21:00 IST nightly. Targets users whose streak would lapse
 * if they don't log a tasting today (no scan / brocard / pair recorded
 * in the last 22 hours, AND streak >= 1).
 *
 * Surfaces loss-aversion that drives return visits — the missing layer
 * called out in STRATEGY-AUDIT P4 (Hook Model: investment loop is
 * unsurfaced because there's no "you're about to lose your N-day
 * streak" notification).
 *
 * Sent as targeted token push (NOT topic) — only at-risk users get it.
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

const STREAK_RISK_HOURS = 22; // last activity > 22h ago = at risk

export const streakLossWarning = onSchedule(
  {
    schedule: "0 21 * * *", // 21:00 IST every day
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
  },
  async () => {
    const firestore = getFirestore();
    const messaging = getMessaging();
    const cutoff = Date.now() - STREAK_RISK_HOURS * 60 * 60 * 1000;

    const snap = await firestore
      .collectionGroup("gamification")
      .where("streak", ">=", 1)
      .get();

    let sent = 0;
    let skipped = 0;
    let errors = 0;

    for (const doc of snap.docs) {
      const data = doc.data();
      const lastActiveStr = data.lastActiveDate as string | undefined;
      if (!lastActiveStr) {
        skipped++;
        continue;
      }
      const lastActive = Date.parse(lastActiveStr);
      if (Number.isNaN(lastActive) || lastActive >= cutoff) {
        skipped++;
        continue;
      }

      // Get the user's FCM token. Schema: users/{uid}/fcm_token document.
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

      const streakDays = data.streak as number;
      try {
        await messaging.send({
          token,
          notification: {
            title: `${streakDays}-day streak — about to lapse`,
            body:
              streakDays === 1
                ? "Don't lose your first day. One quick log keeps it alive."
                : `Don't lose your ${streakDays}-day streak. Log one bottle today.`,
          },
          data: {
            type: "streakLoss",
            streakDays: String(streakDays),
          },
          android: {
            priority: "high",
            notification: { channelId: "streak_loss" },
          },
          apns: {
            payload: { aps: { sound: "default", badge: 1 } },
          },
        });
        sent++;
      } catch (err) {
        errors++;
        console.error(`streakLoss send failed for uid=${uid}:`, err);
      }
    }

    console.log(`streakLossWarning: sent=${sent} skipped=${skipped} errors=${errors}`);
  }
);
