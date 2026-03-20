# WineBro — Cloud Functions Required

## Summary

For Phase 1, the app works **without** cloud functions. All logic runs client-side
with Firestore security rules providing basic protection. However, 4 cloud functions
are **strongly recommended** before public launch to prevent cheating and enable
server-driven features.

---

## CF-01: Streak Calculator (RECOMMENDED — Phase 1)

**Type:** Scheduled Cloud Function (runs daily at 00:05 IST)

**Purpose:** Check each user's `lastActiveDate`. If they missed yesterday, reset
their streak to 0. This prevents the client from maintaining a false streak.

**Logic:**
```
for each user in users/:
  gamState = users/{uid}/gamification/state
  if (today - gamState.lastActiveDate > 1 day):
    gamState.streak = 0
    gamState.save()
```

**Why not client-side?** A user could simply not open the app and keep their streak
frozen. The server must enforce the daily check.

---

## CF-02: XP Validation Trigger (RECOMMENDED — Phase 1)

**Type:** Firestore `onWrite` trigger on `users/{uid}/gamification/state`

**Purpose:** Validate XP changes are within allowed bounds. Prevent a modified
client from awarding arbitrary XP.

**Logic:**
```
xpDelta = newData.xp - oldData.xp
if xpDelta < 0: REJECT (XP can never decrease)
if xpDelta > 100: REJECT (max single action is 50 XP + badge bonus)

// Auto-level-up
if newData.xp >= 5000: newData.level = 3
elif newData.xp >= 1500: newData.level = 2
elif newData.xp >= 500: newData.level = 1
else: newData.level = 0
```

**Why not client-side?** XP is stored in Firestore. A tampered client could write
`xp: 999999`. The trigger validates and corrects.

---

## CF-03: Badge Award Trigger (NICE TO HAVE — Phase 1)

**Type:** Firestore `onWrite` trigger on `users/{uid}/gamification/state`

**Purpose:** Automatically check and award badges server-side when gamification
state changes. Send a push notification via FCM when a badge is earned.

**Logic:**
```
newBadges = checkBadgeConditions(newData)
for badge in newBadges:
  if badge.id not in newData.earnedBadgeIds:
    newData.earnedBadgeIds.append(badge.id)
    newData.xp += badge.xpReward
    sendFCM(uid, "Badge Earned!", badge.name)
```

**Why not client-side?** Badge checks already run client-side (see `GamificationState.checkNewBadges()`).
This function adds server-side verification and FCM notifications. Can defer to Phase 2.

---

## CF-04: Account Cleanup (REQUIRED — before public launch)

**Type:** Firebase Auth `onDelete` trigger

**Purpose:** When a user deletes their account, delete all their subcollections
(journal entries, gamification state) to comply with GDPR/DPDPA.

**Logic:**
```
onUserDeleted(uid):
  delete users/{uid}/journal/*
  delete users/{uid}/gamification/*
  delete users/{uid}
```

**Why cloud function?** Firestore doesn't cascade-delete subcollections.
A client-side delete would miss orphaned data.

---

## CF-05: Daily Discovery Generator (PHASE 2)

**Type:** Scheduled Cloud Function (runs daily at 05:00 IST)

**Purpose:** Generate personalized "Bro's Pick of the Day" for each user using
the pairing engine. Store the result so the app doesn't recompute on every launch.

**Why deferred?** Currently Bro's Pick runs client-side on app launch. This is
fine for <10K users. At scale, pre-computing reduces client load.

---

## What Works WITHOUT Cloud Functions (Phase 1)

| Feature | How it works client-side |
|---------|------------------------|
| Auth | Firebase Auth handles directly |
| Profile creation | Client writes to Firestore (rules validate) |
| Quiz/palate profile | Client writes to Firestore |
| Pairing engine | Pure Dart, runs entirely on-device |
| Journal entries | Client CRUD with Firestore rules |
| Gamification XP/badges | Client updates with rules validating bounds |
| Streak (basic) | Client updates on app open, but cheatable |
| Bro's Pick | Computed on-device per launch |
| Scanner/OCR | Google ML Kit on-device |

---

## Deployment Order

1. **Before any user:** Deploy `firestore.rules` (already written)
2. **Before beta:** Deploy CF-01 (streak) + CF-02 (XP validation)
3. **Before public launch:** Deploy CF-04 (account cleanup)
4. **Phase 2:** Deploy CF-03 (badge notifications) + CF-05 (daily discovery)
