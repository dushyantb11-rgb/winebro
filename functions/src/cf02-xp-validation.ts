/**
 * CF-02 + CF-03 (MERGED): Gamification Validator
 *
 * Single Firestore onWrite trigger on users/{uid}/gamification/state.
 * Handles BOTH XP validation AND badge awards in one pass to avoid
 * the infinite trigger loop that occurs when two separate functions
 * write to the same document path.
 *
 * Flow:
 * 1. Skip if this write was made by this function (sentinel check)
 * 2. Validate XP bounds
 * 3. Calculate correct level
 * 4. Check and award new badges
 * 5. Write all corrections + badges in a single update
 */

import {
  onDocumentWritten,
  FirestoreEvent,
  Change,
} from "firebase-functions/v2/firestore";
import { DocumentSnapshot, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import {
  XP_LEVELS,
  MAX_LEVEL,
  MAX_SINGLE_XP_DELTA,
  BADGES,
  BadgeCondition,
} from "./constants";

const SENTINEL_FIELD = "_lastCorrectedBy";
const FUNCTION_ID = "gamification-validator";

interface GamificationState {
  xp: number;
  level: number;
  streak: number;
  earnedBadgeIds: string[];
  totalScans: number;
  totalJournalEntries: number;
  totalPairings: number;
  totalChallenges: number;
  exploredCategories: Record<string, number>;
  lastActiveDate: string;
  [key: string]: unknown;
}

function calculateLevel(xp: number): number {
  let level = 0;
  for (let l = MAX_LEVEL; l >= 0; l--) {
    if (xp >= XP_LEVELS[l].minXp) {
      level = l;
      break;
    }
  }
  return level;
}

function meetsCondition(
  condition: BadgeCondition,
  state: GamificationState
): boolean {
  switch (condition.type) {
    case "scanCount":
      return state.totalScans >= condition.count;
    case "journalCount":
      return state.totalJournalEntries >= condition.count;
    case "pairingCount":
      return state.totalPairings >= condition.count;
    case "streak":
      return state.streak >= condition.days;
    case "categoryExplored":
      return (state.exploredCategories[condition.category] ?? 0) >= condition.count;
    case "challengeCount":
      return state.totalChallenges >= condition.count;
    case "special":
      return checkSpecial(condition.key, state);
  }
}

function checkSpecial(key: string, state: GamificationState): boolean {
  switch (key) {
    case "indian-wine-3": return (state.exploredCategories["indianWine"] ?? 0) >= 3;
    case "all-aroma-categories": return (state.exploredCategories["aromaCategories"] ?? 0) >= 6;
    case "brocard-10": return (state.exploredCategories["detailedBroCards"] ?? 0) >= 10;
    case "max-level": return state.level >= 3;
    default: return false;
  }
}

export const gamificationValidator = onDocumentWritten(
  {
    document: "users/{uid}/gamification/state",
    memory: "256MiB",
  },
  async (
    event: FirestoreEvent<
      Change<DocumentSnapshot> | undefined,
      { uid: string }
    >
  ) => {
    const change = event.data;
    if (!change) return;

    const after = change.after;
    if (!after.exists) return;

    const newData = after.data() as GamificationState | undefined;
    if (!newData) return;

    // ─── SENTINEL: Skip if this function made the last write ────
    if (newData[SENTINEL_FIELD] === FUNCTION_ID) return;

    const before = change.before;
    const oldData = before.exists ? (before.data() as GamificationState | undefined) : null;

    const updates: Record<string, unknown> = {};
    let needsUpdate = false;

    // ─── STEP 1: VALIDATE XP ─────────────────────────────────
    let effectiveXp = newData.xp;

    if (effectiveXp < 0) {
      effectiveXp = Math.max(oldData?.xp ?? 0, 0);
      updates.xp = effectiveXp;
      needsUpdate = true;
    }

    if (oldData && effectiveXp - oldData.xp > MAX_SINGLE_XP_DELTA) {
      effectiveXp = oldData.xp + MAX_SINGLE_XP_DELTA;
      updates.xp = effectiveXp;
      needsUpdate = true;
    }

    // ─── STEP 2: CALCULATE CORRECT LEVEL ─────────────────────
    const correctLevel = calculateLevel(effectiveXp);
    if (newData.level !== correctLevel) {
      updates.level = correctLevel;
      needsUpdate = true;
    }

    // ─── STEP 3: VALIDATE COUNTS ─────────────────────────────
    if (newData.streak < 0) { updates.streak = 0; needsUpdate = true; }
    for (const f of ["totalScans", "totalJournalEntries", "totalPairings", "totalChallenges"] as const) {
      if (typeof newData[f] === "number" && (newData[f] as number) < 0) {
        updates[f] = 0;
        needsUpdate = true;
      }
    }

    // ─── STEP 4: CHECK & AWARD BADGES ────────────────────────
    // Use the effective state (with corrections applied)
    const effectiveState: GamificationState = {
      ...newData,
      xp: updates.xp !== undefined ? updates.xp as number : effectiveXp,
      level: updates.level !== undefined ? updates.level as number : correctLevel,
    };

    const earnedSet = new Set(newData.earnedBadgeIds ?? []);
    const newBadges = BADGES.filter(
      (b) => !earnedSet.has(b.id) && meetsCondition(b.condition, effectiveState)
    );

    if (newBadges.length > 0) {
      const updatedBadgeIds = [
        ...(newData.earnedBadgeIds ?? []),
        ...newBadges.map((b) => b.id),
      ];
      const bonusXp = newBadges.reduce((sum, b) => sum + b.xpReward, 0);

      updates.earnedBadgeIds = updatedBadgeIds;
      updates.xp = effectiveXp + bonusXp;
      // Recalculate level with badge XP
      updates.level = calculateLevel(effectiveXp + bonusXp);
      needsUpdate = true;
    }

    // ─── STEP 5: WRITE ALL CORRECTIONS IN ONE UPDATE ─────────
    if (needsUpdate) {
      updates[SENTINEL_FIELD] = FUNCTION_ID;
      await after.ref.update(updates);

      console.log(
        `Gamification validator [${event.params.uid}]: ` +
        `corrections=${JSON.stringify(updates)}, ` +
        `newBadges=${newBadges.map((b) => b.name).join(", ") || "none"}`
      );
    }

    // ─── STEP 6: SEND FCM FOR NEW BADGES ─────────────────────
    if (newBadges.length > 0) {
      const db = getFirestore();
      const userDoc = await db.collection("users").doc(event.params.uid).get();
      const fcmToken = userDoc.data()?.fcmToken as string | undefined;

      if (fcmToken) {
        const messaging = getMessaging();
        for (const badge of newBadges) {
          try {
            await messaging.send({
              token: fcmToken,
              notification: {
                title: "Badge Earned!",
                body: `You unlocked "${badge.name}"! +${badge.xpReward} XP`,
              },
              data: {
                type: "badge_earned",
                badgeId: badge.id,
                badgeName: badge.name,
                xpReward: badge.xpReward.toString(),
              },
            });
          } catch (err) {
            console.warn(`FCM failed for badge ${badge.id}:`, err);
          }
        }
      }
    }
  }
);
