/**
 * CF-01: Streak Calculator
 *
 * Scheduled — runs daily at 00:05 IST.
 * Uses a collection group query to find ONLY users with active streaks
 * who missed a day, instead of scanning all users (N+1 fix).
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, WriteBatch } from "firebase-admin/firestore";
import { BATCH_LIMIT } from "./constants";

export const streakCalculator = onSchedule(
  {
    schedule: "35 18 * * *", // 00:05 IST = 18:35 UTC
    timeZone: "Asia/Kolkata",
    retryCount: 3,
    memory: "256MiB",
  },
  async (_event) => {
    const db = getFirestore();
    const now = new Date();

    // Cutoff: anyone whose lastActiveDate is before this missed a day
    const cutoff = new Date(now);
    cutoff.setDate(cutoff.getDate() - 2);
    cutoff.setHours(23, 59, 59, 999);
    const cutoffISO = cutoff.toISOString();

    // Query ONLY gamification docs with streak > 0 and stale lastActiveDate
    // This avoids reading every user — only touches users who need resetting.
    const staleQuery = db
      .collectionGroup("gamification")
      .where("streak", ">", 0)
      .where("lastActiveDate", "<", cutoffISO);

    const snapshot = await staleQuery.get();

    if (snapshot.empty) {
      console.log("Streak calculator: no stale streaks found");
      return;
    }

    let batch: WriteBatch = db.batch();
    let batchCount = 0;

    for (const doc of snapshot.docs) {
      batch.update(doc.ref, { streak: 0 });
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

    console.log(`Streak calculator: reset ${snapshot.size} streaks`);
  }
);
