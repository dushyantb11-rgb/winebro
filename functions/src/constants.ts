/**
 * WineBro Cloud Functions — shared constants.
 * Mirrors the Dart pairing_constants.dart to keep server and client in sync.
 */

// ─── XP LEVELS ──────────────────────────────────────────────
export const XP_LEVELS: Record<number, { name: string; minXp: number }> = {
  0: { name: "Curious Sibling", minXp: 0 },
  1: { name: "Aspiring Taster", minXp: 500 },
  2: { name: "Confident Pairer", minXp: 1500 },
  3: { name: "Wise Elder", minXp: 5000 },
};

export const MAX_LEVEL = 3;

// ─── XP AWARDS ──────────────────────────────────────────────
export const XP_FIRST_SCAN = 50;
export const XP_SUBSEQUENT_SCAN = 15;
export const XP_FIRST_PAIRING = 25;
export const XP_FIRST_JOURNAL = 50;
export const XP_SUBSEQUENT_JOURNAL = 20;
export const XP_BROCARD = 25;
export const XP_BROCARD_DETAILED = 50;
export const XP_CORRECT_CHALLENGE = 30;
export const XP_CORRECT_BLIND_TASTING = 50;
export const XP_AROMA_EXPLORED = 15;

// Max XP from a single user action (largest award + badge XP)
export const MAX_SINGLE_XP_DELTA = 150;

// ─── BADGE DEFINITIONS ──────────────────────────────────────
export interface BadgeDef {
  id: string;
  name: string;
  xpReward: number;
  condition: BadgeCondition;
}

export type BadgeCondition =
  | { type: "scanCount"; count: number }
  | { type: "journalCount"; count: number }
  | { type: "pairingCount"; count: number }
  | { type: "streak"; days: number }
  | { type: "categoryExplored"; category: string; count: number }
  | { type: "challengeCount"; count: number }
  | { type: "special"; key: string };

export const BADGES: BadgeDef[] = [
  { id: "first-scan", name: "Eagle Eye", xpReward: 50, condition: { type: "scanCount", count: 1 } },
  { id: "scan-master", name: "Scan Master", xpReward: 200, condition: { type: "scanCount", count: 50 } },
  { id: "first-note", name: "The Pen", xpReward: 50, condition: { type: "journalCount", count: 1 } },
  { id: "journal-10", name: "Sommelier in Training", xpReward: 100, condition: { type: "journalCount", count: 10 } },
  { id: "journal-50", name: "Dedicated Taster", xpReward: 500, condition: { type: "journalCount", count: 50 } },
  { id: "first-pair", name: "Matchmaker", xpReward: 50, condition: { type: "pairingCount", count: 1 } },
  { id: "pair-25", name: "Pairing Pro", xpReward: 200, condition: { type: "pairingCount", count: 25 } },
  { id: "streak-3", name: "Getting Serious", xpReward: 50, condition: { type: "streak", days: 3 } },
  { id: "streak-7", name: "On Fire", xpReward: 100, condition: { type: "streak", days: 7 } },
  { id: "streak-30", name: "Iron Will", xpReward: 500, condition: { type: "streak", days: 30 } },
  { id: "red-explorer", name: "Red Explorer", xpReward: 100, condition: { type: "categoryExplored", category: "redWine", count: 5 } },
  { id: "white-explorer", name: "White Wanderer", xpReward: 100, condition: { type: "categoryExplored", category: "whiteWine", count: 5 } },
  { id: "whisky-explorer", name: "Spirit Guide", xpReward: 100, condition: { type: "categoryExplored", category: "whisky", count: 5 } },
  { id: "beer-explorer", name: "Hop Head", xpReward: 100, condition: { type: "categoryExplored", category: "beer", count: 5 } },
  { id: "indian-wine", name: "Swadeshi Sipper", xpReward: 100, condition: { type: "special", key: "indian-wine-3" } },
  { id: "challenge-5", name: "Challenger", xpReward: 100, condition: { type: "challengeCount", count: 5 } },
  { id: "challenge-25", name: "Challenge Champion", xpReward: 300, condition: { type: "challengeCount", count: 25 } },
  { id: "aroma-master", name: "Nose Knows", xpReward: 200, condition: { type: "special", key: "all-aroma-categories" } },
  { id: "brocard-master", name: "BroCard Master", xpReward: 300, condition: { type: "special", key: "brocard-10" } },
  { id: "wise-elder", name: "Wise Elder", xpReward: 1000, condition: { type: "special", key: "max-level" } },
];

// ─── PAIRING ENGINE CONSTANTS ───────────────────────────────
export const AXIS_WEIGHTS = {
  fruit: 1.0,
  acidity: 1.2,
  body: 1.1,
  tannin: 0.9,
  freshness: 0.8,
  complexity: 1.0,
};

export const SCORE_FLOOR = 40;
export const SCORE_CEILING = 99;

export type PalateAxes = {
  fruit: number;
  acidity: number;
  body: number;
  tannin: number;
  freshness: number;
  complexity: number;
};

// ─── ARCHETYPE BONUSES (must match Dart PalateArchetype.bonusPercent) ─
export const ARCHETYPE_BONUSES: Record<string, number> = {
  boldExplorer: 15,
  crispPurist: 12,
  fruitForward: 10,
  balancedSipper: 5,
  sweetTooth: 12,
};

// ─── BATCH LIMITS ───────────────────────────────────────────
export const BATCH_LIMIT = 400; // Firestore batch limit is 500, leave margin
