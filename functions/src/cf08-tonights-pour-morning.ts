/**
 * CF-08: Tonight's Pour Morning Push
 *
 * Scheduled 07:00 IST. Sends to users who've been inactive >3 hours
 * (i.e. likely starting their day on the phone). Topic broadcast to
 * `tonightsPour` topic; the device app re-loads the hero card on
 * tap so the curated daily pour shows.
 *
 * Topic broadcast keeps this lightweight — actual product targeting
 * happens device-side in tonightsPourProvider.
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { getMessaging } from "firebase-admin/messaging";

const MORNING_TITLES = [
  "Tonight's Pour is ready",
  "Bro picked tonight's bottle",
  "Your evening starts here",
  "Tonight, you should taste...",
];

const MORNING_BODIES = [
  "Tap to see the curated bottle Bro picked for your palate today.",
  "A bottle, hand-picked. Open the app to find tonight's pour.",
  "Bro thought about it. There's a bottle waiting for tonight.",
];

function pickFromArray<T>(arr: T[], seed: number): T {
  return arr[seed % arr.length];
}

export const tonightsPourMorning = onSchedule(
  {
    schedule: "0 7 * * *", // 07:00 IST every day
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
  },
  async () => {
    const messaging = getMessaging();
    const daySeed = Math.floor(Date.now() / (1000 * 60 * 60 * 24));

    try {
      await messaging.send({
        topic: "tonightsPour",
        notification: {
          title: pickFromArray(MORNING_TITLES, daySeed),
          body: pickFromArray(MORNING_BODIES, daySeed),
        },
        data: {
          type: "tonightsPour",
        },
        android: {
          priority: "normal",
          notification: {
            channelId: "tonights_pour",
            tag: "tonightsPour_daily",
          },
        },
        apns: {
          payload: { aps: { sound: "default" } },
        },
      });
    } catch (err) {
      console.error("tonightsPourMorning send failed:", err);
    }
  }
);
