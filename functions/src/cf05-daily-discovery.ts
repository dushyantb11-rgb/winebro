/**
 * CF-05: Daily Discovery Generator (Bro's Pick)
 *
 * Scheduled function running daily at 05:00 IST.
 * For each user with a palate profile, computes a personalized "Bro's Pick"
 * using a server-side port of the weighted cosine similarity algorithm.
 * Stores the result so the app doesn't recompute on every launch.
 *
 * This is the same math as the Dart PairingEngine — ported to TypeScript.
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import {
  getFirestore,
  WriteBatch,
  DocumentData,
} from "firebase-admin/firestore";
import {
  AXIS_WEIGHTS,
  SCORE_FLOOR,
  SCORE_CEILING,
  ARCHETYPE_BONUSES,
  BATCH_LIMIT,
  PalateAxes,
} from "./constants";

// ─── SEED PRODUCT PROFILES (top 20 for daily pick rotation) ─────
// These mirror the Dart seed data. In production, read from Firestore.
// SYNC WITH: lib/features/pairing/data/seed_products.dart
// Last synced: 2026-03-14
// If product axis scores change in Dart, update this array.
const SEED_PRODUCTS: Array<{ id: string; name: string; axes: PalateAxes; archetypeTags: string[] }> = [
  { id: "sula-sauvignon-blanc", name: "Sula Vineyards Sauvignon Blanc", axes: { fruit: 6, acidity: 7, body: 3, tannin: 1, freshness: 8, complexity: 4 }, archetypeTags: ["crispPurist"] },
  { id: "sula-shiraz", name: "Sula Vineyards Shiraz", axes: { fruit: 6, acidity: 5, body: 7, tannin: 6, freshness: 3, complexity: 5 }, archetypeTags: ["boldExplorer"] },
  { id: "grover-zampa-la-reserve", name: "Grover Zampa La Réserve", axes: { fruit: 5, acidity: 5, body: 8, tannin: 7, freshness: 3, complexity: 7 }, archetypeTags: ["boldExplorer"] },
  { id: "fratelli-tilt-rose", name: "Fratelli TILT Rosé", axes: { fruit: 7, acidity: 6, body: 3, tannin: 2, freshness: 7, complexity: 3 }, archetypeTags: ["fruitForward"] },
  { id: "krsma-cabernet-sauvignon", name: "KRSMA Cabernet Sauvignon", axes: { fruit: 5, acidity: 5, body: 9, tannin: 8, freshness: 2, complexity: 8 }, archetypeTags: ["boldExplorer"] },
  { id: "cloudy-bay-sauvignon-blanc", name: "Cloudy Bay Sauvignon Blanc", axes: { fruit: 7, acidity: 8, body: 3, tannin: 1, freshness: 9, complexity: 5 }, archetypeTags: ["crispPurist"] },
  { id: "catena-zapata-malbec", name: "Catena Zapata Malbec", axes: { fruit: 7, acidity: 5, body: 8, tannin: 7, freshness: 3, complexity: 7 }, archetypeTags: ["boldExplorer"] },
  { id: "amrut-fusion", name: "Amrut Fusion", axes: { fruit: 5, acidity: 3, body: 8, tannin: 4, freshness: 3, complexity: 8 }, archetypeTags: ["boldExplorer"] },
  { id: "paul-john-brilliance", name: "Paul John Brilliance", axes: { fruit: 6, acidity: 3, body: 7, tannin: 3, freshness: 4, complexity: 7 }, archetypeTags: ["boldExplorer"] },
  { id: "glenfiddich-12", name: "Glenfiddich 12 Year Old", axes: { fruit: 7, acidity: 4, body: 5, tannin: 2, freshness: 5, complexity: 6 }, archetypeTags: ["balancedSipper"] },
  { id: "lagavulin-16", name: "Lagavulin 16 Year Old", axes: { fruit: 3, acidity: 4, body: 8, tannin: 5, freshness: 3, complexity: 9 }, archetypeTags: ["boldExplorer"] },
  { id: "bira-91-white", name: "Bira 91 White", axes: { fruit: 6, acidity: 4, body: 3, tannin: 1, freshness: 7, complexity: 3 }, archetypeTags: ["crispPurist"] },
  { id: "hoegaarden", name: "Hoegaarden", axes: { fruit: 5, acidity: 4, body: 3, tannin: 1, freshness: 7, complexity: 4 }, archetypeTags: ["crispPurist"] },
  { id: "moet-chandon-imperial", name: "Moët & Chandon Impérial", axes: { fruit: 6, acidity: 7, body: 4, tannin: 1, freshness: 8, complexity: 7 }, archetypeTags: ["crispPurist"] },
  { id: "penfolds-bin-389", name: "Penfolds Bin 389", axes: { fruit: 6, acidity: 5, body: 8, tannin: 7, freshness: 3, complexity: 8 }, archetypeTags: ["boldExplorer"] },
  { id: "monkey-shoulder", name: "Monkey Shoulder", axes: { fruit: 6, acidity: 3, body: 5, tannin: 2, freshness: 5, complexity: 5 }, archetypeTags: ["balancedSipper"] },
  { id: "soma-chenin-blanc", name: "Soma Vine Village Chenin Blanc", axes: { fruit: 7, acidity: 6, body: 3, tannin: 1, freshness: 7, complexity: 3 }, archetypeTags: ["fruitForward"] },
  { id: "sierra-nevada-pale-ale", name: "Sierra Nevada Pale Ale", axes: { fruit: 5, acidity: 4, body: 5, tannin: 4, freshness: 6, complexity: 5 }, archetypeTags: ["balancedSipper"] },
  { id: "torres-vina-sol", name: "Torres Viña Sol", axes: { fruit: 6, acidity: 6, body: 3, tannin: 1, freshness: 7, complexity: 3 }, archetypeTags: ["crispPurist"] },
  { id: "chimay-blue", name: "Chimay Blue", axes: { fruit: 6, acidity: 4, body: 8, tannin: 3, freshness: 3, complexity: 8 }, archetypeTags: ["boldExplorer"] },
];

/**
 * Weighted cosine similarity — same formula as Dart PairingEngine.
 *
 * score = Σ(w_i * u_i * p_i) / (√Σ(w_i * u_i²) * √Σ(w_i * p_i²)) * 100
 */
function weightedCosineSimilarity(
  user: PalateAxes,
  product: PalateAxes
): number {
  const axes: (keyof PalateAxes)[] = [
    "fruit", "acidity", "body", "tannin", "freshness", "complexity",
  ];

  let dotProduct = 0;
  let userMagnitude = 0;
  let productMagnitude = 0;

  for (const axis of axes) {
    const w = AXIS_WEIGHTS[axis];
    const u = user[axis];
    const p = product[axis];
    dotProduct += w * u * p;
    userMagnitude += w * u * u;
    productMagnitude += w * p * p;
  }

  const denominator = Math.sqrt(userMagnitude) * Math.sqrt(productMagnitude);
  if (denominator === 0) return SCORE_FLOOR;

  return (dotProduct / denominator) * 100;
}

/**
 * Rank products for a user and return the top pick.
 * Includes archetype bonus.
 */
function pickBrosChoice(
  userAxes: PalateAxes,
  userArchetype: string,
  dayOfYear: number
): { id: string; name: string; score: number } {
  const scored = SEED_PRODUCTS.map((product) => {
    const baseScore = weightedCosineSimilarity(userAxes, product.axes);
    const archetypeBonus = product.archetypeTags.includes(userArchetype)
      ? (ARCHETYPE_BONUSES[userArchetype] ?? 5)
      : 0;
    const score = Math.min(
      SCORE_CEILING,
      Math.max(SCORE_FLOOR, baseScore + archetypeBonus)
    );
    return { ...product, score };
  });

  scored.sort((a, b) => b.score - a.score);

  // Rotate through top 5 based on day of year to avoid same pick daily
  const topN = scored.slice(0, 5);
  const index = dayOfYear % topN.length;

  return topN[index];
}

export const dailyDiscovery = onSchedule(
  {
    schedule: "30 23 * * *", // 05:00 IST = 23:30 UTC previous day
    timeZone: "Asia/Kolkata",
    retryCount: 3,
    memory: "512MiB",
  },
  async (_event) => {
    const db = getFirestore();
    const now = new Date();
    const dayOfYear = Math.floor(
      (now.getTime() - new Date(now.getFullYear(), 0, 0).getTime()) /
        (1000 * 60 * 60 * 24)
    );

    const usersSnapshot = await db.collection("users").get();
    let batch: WriteBatch = db.batch();
    let batchCount = 0;
    let pickCount = 0;

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data() as DocumentData;
      const palateProfile = userData.palateProfile as
        | (PalateAxes & { archetype: string })
        | undefined;

      if (!palateProfile) continue;

      const userAxes: PalateAxes = {
        fruit: palateProfile.fruit ?? 5,
        acidity: palateProfile.acidity ?? 5,
        body: palateProfile.body ?? 5,
        tannin: palateProfile.tannin ?? 5,
        freshness: palateProfile.freshness ?? 5,
        complexity: palateProfile.complexity ?? 5,
      };

      const pick = pickBrosChoice(
        userAxes,
        palateProfile.archetype ?? "balancedSipper",
        dayOfYear
      );

      batch.set(
        userDoc.ref.collection("dailyPick").doc("today"),
        {
          productId: pick.id,
          productName: pick.name,
          matchScore: Math.round(pick.score),
          generatedAt: now.toISOString(),
          dayOfYear,
        },
        { merge: true }
      );

      batchCount++;
      pickCount++;

      if (batchCount >= BATCH_LIMIT) {
        await batch.commit();
        batch = db.batch();
        batchCount = 0;
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    console.log(
      `Daily discovery: generated picks for ${pickCount} of ${usersSnapshot.size} users`
    );
  }
);
