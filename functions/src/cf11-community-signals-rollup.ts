/**
 * CF-11: Community Signals Rollup
 *
 * Daily cron at 02:00 IST (off-peak). Aggregates the last 14 days of
 * journal writes from collectionGroup('journal') into the public
 * `community_signals/{productId}` collection so the Bro Circle on
 * Home can surface real numbers instead of synthetic placeholders.
 *
 * Output shape per product:
 *   tastersThisWeek    int   unique uids who logged in last 7d
 *   lovedThisWeek      int   unique uids who rated 4-5 in last 7d
 *   climbingScore      number  thisWeek/(prevWeek + 1) - 1   (delta)
 *   topPairing         string  most common foodPaired (or null)
 *   topPairingShare    number  ratio of entries with that pairing
 *   lovedRate          number  lovedThisWeek / tastersThisWeek
 *   updatedAt          serverTimestamp
 *
 * Read by app's communitySignalsProvider; gates: tastersThisWeek > 0.
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

interface ProductBucket {
  productName: string;
  category: string;
  region: string;
  uidsThisWeek: Set<string>;
  uidsPrevWeek: Set<string>;
  lovedUidsThisWeek: Set<string>;
  pairings: Record<string, number>;
}

export const communitySignalsRollup = onSchedule(
  {
    schedule: "0 2 * * *", // 02:00 IST every day
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
  },
  async () => {
    const firestore = getFirestore();
    const now = Date.now();
    const oneWeekMs = 7 * 24 * 60 * 60 * 1000;
    const fourteenDaysAgo = new Date(now - 14 * oneWeekMs / 7).toISOString();
    const sevenDaysAgo = new Date(now - oneWeekMs).toISOString();

    // collectionGroup query — uses the existing journal createdAt
    // index added in S2.1 (CF-09). No new index required.
    const snap = await firestore
      .collectionGroup("journal")
      .where("createdAt", ">=", fourteenDaysAgo)
      .get();

    const buckets = new Map<string, ProductBucket>();

    for (const doc of snap.docs) {
      const data = doc.data();
      const productId = data.productId as string | undefined;
      if (!productId) continue;
      const uid = doc.ref.parent.parent?.id;
      if (!uid) continue;
      const createdAt = data.createdAt as string | undefined;
      if (!createdAt) continue;

      const isThisWeek = createdAt >= sevenDaysAgo;
      const rating = (data.rating as number | undefined) ?? 0;
      const foodPaired = data.foodPaired as string | undefined;

      let bucket = buckets.get(productId);
      if (!bucket) {
        bucket = {
          productName: (data.productName as string) ?? "",
          category: (data.category as string) ?? "",
          region: (data.region as string) ?? "",
          uidsThisWeek: new Set(),
          uidsPrevWeek: new Set(),
          lovedUidsThisWeek: new Set(),
          pairings: {},
        };
        buckets.set(productId, bucket);
      }

      if (isThisWeek) {
        bucket.uidsThisWeek.add(uid);
        if (rating >= 4) bucket.lovedUidsThisWeek.add(uid);
        if (foodPaired) {
          bucket.pairings[foodPaired] =
            (bucket.pairings[foodPaired] ?? 0) + 1;
        }
      } else {
        bucket.uidsPrevWeek.add(uid);
      }
    }

    let written = 0;
    const writer = firestore.bulkWriter();

    for (const [productId, b] of buckets) {
      const tastersThisWeek = b.uidsThisWeek.size;
      const tastersPrevWeek = b.uidsPrevWeek.size;
      const lovedThisWeek = b.lovedUidsThisWeek.size;

      // Skip if zero — keep collection lean.
      if (tastersThisWeek === 0 && tastersPrevWeek === 0) continue;

      const climbingScore =
        tastersPrevWeek === 0
          ? tastersThisWeek > 0 ? 1 : 0
          : tastersThisWeek / (tastersPrevWeek + 1) - 1;

      let topPairing: string | null = null;
      let topPairingCount = 0;
      for (const [pair, count] of Object.entries(b.pairings)) {
        if (count > topPairingCount) {
          topPairing = pair;
          topPairingCount = count;
        }
      }
      const totalPairings = Object.values(b.pairings).reduce(
        (s, n) => s + n,
        0
      );
      const topPairingShare =
        totalPairings === 0 ? 0 : topPairingCount / totalPairings;

      const lovedRate =
        tastersThisWeek === 0 ? 0 : lovedThisWeek / tastersThisWeek;

      const docRef = firestore
        .collection("community_signals")
        .doc(productId);
      writer.set(
        docRef,
        {
          productId,
          productName: b.productName,
          category: b.category,
          region: b.region,
          tastersThisWeek,
          tastersPrevWeek,
          lovedThisWeek,
          climbingScore,
          topPairing,
          topPairingShare,
          lovedRate,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      written++;
    }

    await writer.close();
    console.log(
      `communitySignalsRollup: products=${buckets.size} written=${written}`
    );
  }
);
