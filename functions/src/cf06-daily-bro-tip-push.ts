/**
 * CF-06: Daily Bro Tip Push
 *
 * Scheduled 20:00 IST every day. Sends one Bro Tip push per archetype
 * topic via FCM topic broadcast. The on-device handler routes the tap
 * to /home and surfaces the tip card.
 *
 * Topics:
 *   broTip                   universal — "general" tips
 *   broTip_boldExplorer      archetype-specific
 *   broTip_crispPurist
 *   broTip_fruitForward
 *   broTip_balancedSipper
 *   broTip_sweetTooth
 *
 * App-side, NotificationHandler.subscribeAll() subscribes to broTip;
 * after the quiz the app additionally subscribes to the user's
 * archetype topic so they get archetype-specific tips on top of the
 * generic broadcast.
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { getMessaging } from "firebase-admin/messaging";
import { BRO_TIPS, pickTipForArchetype, BroTip } from "./seed_bro_tips";

const ARCHETYPES: BroTip["archetype"][] = [
  "general",
  "boldExplorer",
  "crispPurist",
  "fruitForward",
  "balancedSipper",
  "sweetTooth",
];

export const dailyBroTipPush = onSchedule(
  {
    schedule: "0 20 * * *", // 20:00 IST every day
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
  },
  async () => {
    const messaging = getMessaging();
    const daySeed =
      Math.floor(Date.now() / (1000 * 60 * 60 * 24)) % BRO_TIPS.length;

    for (const archetype of ARCHETYPES) {
      const tip = pickTipForArchetype(archetype, daySeed);
      const topic =
        archetype === "general" ? "broTip" : `broTip_${archetype}`;

      try {
        await messaging.send({
          topic,
          notification: {
            title: "Bro Tip of the Day",
            body: tip.body,
          },
          data: {
            type: "broTip",
            tipId: tip.id,
          },
          android: {
            priority: "normal",
            notification: {
              channelId: "bro_tip",
              tag: `broTip_${tip.id}`,
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        });
      } catch (err) {
        console.error(`Failed to send Bro Tip to topic ${topic}:`, err);
      }
    }
  }
);
