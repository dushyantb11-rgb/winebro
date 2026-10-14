/**
 * WineBro — Firebase Cloud Functions
 *
 * CF-01: streakCalculator       — Daily cron, resets broken streaks
 * CF-02: gamificationEvents     — Firestore trigger on users/{uid}/events; server-authoritative XP/streak/badges
 * CF-04: deleteAccount          — Callable, GDPR data deletion
 * CF-04b: userDocCleanup        — Firestore trigger, orphaned subcollection cleanup
 * CF-05: retired 2026-09-27 — its users/{uid}/dailyPick was never read by the
 *        app (no read rule); Tonight's Pour is computed on the device.
 * CF-06: dailyBroTipPush        — 20:00 IST, archetype-keyed Bro Tip topic broadcasts
 * CF-07: streakLossWarning      — 21:00 IST, targeted push to at-risk streak holders
 * CF-08: tonightsPourMorning    — 07:00 IST, topic broadcast for daily curated bottle
 * CF-09: pairingFeedback24h     — hourly cron, "Did Bro get it right?" 24h after journal save
 * CF-10: restockSundayPush      — Sundays 11:00 IST, "time to restock?" push for buy-again 28-35d ago
 * CF-11: communitySignalsRollup — daily 02:00 IST, aggregates 14d journal writes into community_signals/
 * CF-12: adminApi              — HTTPS JSON API for the admin web app (Hosting /api/**)
 * CF-12b: pairingFeedbackAggregate — Firestore trigger, server-side yes/maybe/no aggregates
 * CF-13: registerPhoneIndex / lookupContacts — callables replacing the public phone_index
 */

import { initializeApp } from "firebase-admin/app";

initializeApp();

export { streakCalculator } from "./cf01-streak-calculator";
export { gamificationEvents } from "./cf02-gamification-events";
export { deleteAccount, userDocCleanup } from "./cf04-account-cleanup";
export { dailyBroTipPush } from "./cf06-daily-bro-tip-push";
export { streakLossWarning } from "./cf07-streak-loss-warning";
export { tonightsPourMorning } from "./cf08-tonights-pour-morning";
export { pairingFeedback24h } from "./cf09-pairing-feedback-24h";
export { restockSundayPush } from "./cf10-restock-sunday-push";
export { communitySignalsRollup } from "./cf11-community-signals-rollup";
export { adminApi } from "./admin/api";
export { pairingFeedbackAggregate } from "./cf12-pairing-feedback-aggregate";
export { registerPhoneIndex, lookupContacts } from "./cf13-phone-index";
