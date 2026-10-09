/**
 * CF-02: Gamification event processor (server-authoritative).
 *
 * The app never writes users/{uid}/gamification/state. It appends an
 * immutable event to users/{uid}/events/{eventId}:
 *   { type: "scan" | "journalEntry" | "pairing", category?, withFoodPairing?, createdAt }
 * This trigger applies the event inside a transaction: counters, streak
 * (Asia/Kolkata calendar days), XP from config/gamification.actions,
 * badges from config/badges, level from config/gamification.levels.
 * Each event is marked processedAt so a retried delivery is a no-op.
 */
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { sendToUser } from "./push";

type EventType = "scan" | "journalEntry" | "pairing";
const EVENT_TYPES = new Set<EventType>(["scan", "journalEntry", "pairing"]);

interface State {
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
  lastEventId?: string;
}

interface Badge {
  id: string;
  name: string;
  xpReward: number;
  condition: { type: string; value: unknown };
}

interface Rules {
  actions: Record<string, number>;
  levels: { level: number; minXp: number }[];
  badges: Badge[];
}

let rulesCache: { at: number; rules: Rules } | null = null;

async function loadRules(): Promise<Rules> {
  if (rulesCache && Date.now() - rulesCache.at < 60_000) return rulesCache.rules;
  const db = getFirestore();
  const [g, b] = await Promise.all([
    db.collection("config").doc("gamification").get(),
    db.collection("config").doc("badges").get(),
  ]);
  const actions = (g.get("actions") as Record<string, number> | undefined) ?? { scan: 5, journalEntry: 10, pairing: 5 };
  const levelsRaw = (g.get("levels") as { level: number; minXp: number }[] | undefined) ?? [{ level: 0, minXp: 0 }];
  const levels = [...levelsRaw].sort((x, y) => x.minXp - y.minXp);
  const badges = (b.get("items") as Badge[] | undefined) ?? [];
  const rules = { actions, levels, badges };
  rulesCache = { at: Date.now(), rules };
  return rules;
}

/** Calendar date (YYYY-MM-DD) in Asia/Kolkata. */
function istDate(d: Date): string {
  return new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Kolkata", year: "numeric", month: "2-digit", day: "2-digit" }).format(d);
}

function daysBetween(a: string, b: string): number {
  return Math.round((Date.parse(b) - Date.parse(a)) / 86_400_000);
}

function levelFor(xp: number, levels: Rules["levels"]): number {
  let best = levels[0]?.level ?? 0;
  for (const l of levels) if (xp >= l.minXp && l.level > best) best = l.level;
  return best;
}

function meets(badge: Badge, s: State, maxLevel: number): boolean {
  const n = typeof badge.condition.value === "number" ? badge.condition.value : Number(badge.condition.value) || 0;
  switch (badge.condition.type) {
    case "scanCount": return s.totalScans >= n;
    case "journalCount": return s.totalJournalEntries >= n;
    case "pairingCount": return s.totalPairings >= n;
    case "streakDays": return s.streak >= n;
    case "challengeCount": return s.totalChallenges >= n;
    case "categoryExplored": return (s.exploredCategories[String(badge.condition.value)] ?? 0) >= 5;
    case "special":
      switch (String(badge.condition.value)) {
        case "indian-wine-3": return (s.exploredCategories["indianWine"] ?? 0) >= 3;
        case "all-aroma-categories": return (s.exploredCategories["aromaCategories"] ?? 0) >= 6;
        case "brocard-10": return (s.exploredCategories["detailedBroCards"] ?? 0) >= 10;
        case "max-level": return s.level >= maxLevel;
        default: return false;
      }
    default: return false;
  }
}

function initial(today: string): State {
  return {
    xp: 0, level: 0, streak: 0, earnedBadgeIds: [], totalScans: 0, totalJournalEntries: 0,
    totalPairings: 0, totalChallenges: 0, exploredCategories: {}, lastActiveDate: today,
  };
}

export const gamificationEvents = onDocumentCreated(
  { document: "users/{uid}/events/{eventId}", region: "asia-south1", memory: "256MiB" },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const uid = event.params.uid;
    const data = snap.data();
    const type = data.type as EventType;
    if (!EVENT_TYPES.has(type)) {
      console.warn(`events/${snap.id} for ${uid}: unknown type ${String(data.type)}`);
      return;
    }
    const createdAt = data.createdAt instanceof Timestamp ? data.createdAt.toDate() : new Date();
    const today = istDate(createdAt);
    const rules = await loadRules();
    const db = getFirestore();
    const stateRef = db.collection("users").doc(uid).collection("gamification").doc("state");

    const outcome = await db.runTransaction(async (tx) => {
      const [stateSnap, eventSnap] = await Promise.all([tx.get(stateRef), tx.get(snap.ref)]);
      if (!eventSnap.exists || eventSnap.get("processedAt")) return null; // already applied or deleted
      const prev = stateSnap.exists ? ({ ...initial(today), ...(stateSnap.data() as Partial<State>) } as State) : initial(today);
      const s: State = { ...prev, exploredCategories: { ...prev.exploredCategories }, earnedBadgeIds: [...prev.earnedBadgeIds] };

      // 1. counters
      if (type === "scan") s.totalScans++;
      if (type === "journalEntry") s.totalJournalEntries++;
      if (type === "pairing") s.totalPairings++;
      if (type === "journalEntry" && data.withFoodPairing === true) s.totalPairings++;

      // 2. category exploration
      const category = typeof data.category === "string" ? data.category.trim() : "";
      if (category) s.exploredCategories[category] = (s.exploredCategories[category] ?? 0) + 1;

      // 3. streak on Asia/Kolkata calendar days
      const gap = prev.lastActiveDate ? daysBetween(prev.lastActiveDate.slice(0, 10), today) : 0;
      if (!stateSnap.exists || prev.streak === 0) s.streak = 1;
      else if (gap === 0) s.streak = prev.streak;
      else if (gap === 1) s.streak = prev.streak + 1;
      else s.streak = 1;
      s.lastActiveDate = today;

      // 4. XP for the action
      let xp = rules.actions[type] ?? 0;
      if (type === "journalEntry" && data.withFoodPairing === true) xp += rules.actions["pairing"] ?? 0;
      s.xp = prev.xp + xp;
      s.level = levelFor(s.xp, rules.levels);

      // 5. badges (may unlock further badges, e.g. max-level)
      const maxLevel = Math.max(...rules.levels.map((l) => l.level));
      const newBadges: Badge[] = [];
      for (let pass = 0; pass < 3; pass++) {
        const earned = new Set(s.earnedBadgeIds);
        const unlocked = rules.badges.filter((b) => !earned.has(b.id) && meets(b, s, maxLevel));
        if (!unlocked.length) break;
        for (const b of unlocked) {
          s.earnedBadgeIds.push(b.id);
          s.xp += b.xpReward;
          newBadges.push(b);
        }
        s.level = levelFor(s.xp, rules.levels);
      }

      s.lastEventId = snap.id;
      tx.set(stateRef, { ...s, updatedAt: FieldValue.serverTimestamp() });
      tx.update(snap.ref, { processedAt: FieldValue.serverTimestamp(), xpAwarded: s.xp - prev.xp });
      return { newBadges, xpAwarded: s.xp - prev.xp };
    });

    if (!outcome) return;
    console.log(`gamification ${uid}: ${type} +${outcome.xpAwarded} XP, badges=${outcome.newBadges.map((b) => b.id).join(",") || "none"}`);
    for (const badge of outcome.newBadges) {
      await sendToUser(uid, {
        notification: { title: "Badge earned!", body: `You unlocked "${badge.name}" — +${badge.xpReward} XP` },
        data: { type: "badgeEarned", badgeId: badge.id, badgeName: badge.name, xpReward: String(badge.xpReward) },
      });
    }
  },
);
