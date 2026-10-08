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

type CatalogProduct = {
  id: string;
  name: string;
  axes: PalateAxes;
  archetypeTags: string[];
};

/** Loads the drink catalogue from Firestore `products`. */
async function loadCatalog(
  db: FirebaseFirestore.Firestore
): Promise<CatalogProduct[]> {
  const snap = await db.collection("products").get();
  const products: CatalogProduct[] = [];
  for (const doc of snap.docs) {
    const d = doc.data();
    const axes = {
      fruit: d.fruit, acidity: d.acidity, body: d.body,
      tannin: d.tannin, freshness: d.freshness, complexity: d.complexity,
    };
    if (Object.values(axes).some((v) => typeof v !== "number")) {
      console.warn(`dailyDiscovery: skipping products/${doc.id}, missing axes`);
      continue;
    }
    products.push({
      id: doc.id,
      name: String(d.name ?? doc.id),
      axes: axes as PalateAxes,
      archetypeTags: Array.isArray(d.archetypeTags) ? d.archetypeTags : [],
    });
  }
  return products;
}

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
  catalog: CatalogProduct[],
  userAxes: PalateAxes,
  userArchetype: string,
  dayOfYear: number
): { id: string; name: string; score: number } {
  const scored = catalog.map((product) => {
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

    const catalog = await loadCatalog(db);
    if (catalog.length === 0) {
      console.warn("dailyDiscovery: products collection is empty, no picks written");
      return;
    }

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
        catalog,
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
