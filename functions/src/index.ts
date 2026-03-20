/**
 * WineBro — Firebase Cloud Functions
 *
 * CF-01: streakCalculator     — Daily cron, resets broken streaks
 * CF-02: gamificationValidator — Firestore trigger, XP validation + badge awards (merged)
 * CF-04: deleteAccount        — Callable, GDPR data deletion
 * CF-04b: userDocCleanup      — Firestore trigger, orphaned subcollection cleanup
 * CF-05: dailyDiscovery       — Daily cron, pre-computes Bro's Pick per user
 */

import { initializeApp } from "firebase-admin/app";

initializeApp();

export { streakCalculator } from "./cf01-streak-calculator";
export { gamificationValidator } from "./cf02-xp-validation";
export { deleteAccount, userDocCleanup } from "./cf04-account-cleanup";
export { dailyDiscovery } from "./cf05-daily-discovery";
