import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/profile/domain/gamification.dart';

/// One discrete action that can fire streak / XP / badge progress.
/// Callers stay agnostic to the math — they just say "the user did X".
enum GamificationAction {
  scan(xp: 5),
  journalEntry(xp: 10),
  pairing(xp: 5);

  const GamificationAction({required this.xp});
  final int xp;
}

/// Single owner of streak/XP firing. Wired into:
///   - Scanner match success
///   - Quick-log save (always; +pairing bonus if foodPaired set)
///   - Future: BroCard detailed save, daily challenge complete
///
/// Writes are validated server-side by CF-02 gamificationValidator
/// (anti-cheat). This service stays optimistic — local state updates
/// immediately so the UI reflects progress without waiting on the
/// round-trip; if the validator rejects a diff, it'll roll back via
/// the next snapshot.
class GamificationService {
  GamificationService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> recordAction(
    GamificationAction action, {
    String? category,
    bool withFoodPairing = false,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ref = _firestore
        .collection('users')
        .doc(uid)
        .collection('gamification')
        .doc('state');

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      var state = snap.exists
          ? GamificationState.fromMap(snap.data()!)
          : GamificationState.initial();

      // 1. Counter delta
      switch (action) {
        case GamificationAction.scan:
          state = state.copyWith(totalScans: state.totalScans + 1);
        case GamificationAction.journalEntry:
          state = state.copyWith(
            totalJournalEntries: state.totalJournalEntries + 1,
          );
        case GamificationAction.pairing:
          state = state.copyWith(totalPairings: state.totalPairings + 1);
      }
      // A journal entry that captured foodPaired is also a pairing.
      if (action == GamificationAction.journalEntry && withFoodPairing) {
        state = state.copyWith(totalPairings: state.totalPairings + 1);
      }

      // 2. Category exploration
      if (category != null && category.isNotEmpty) {
        final updated = Map<String, int>.from(state.exploredCategories);
        updated[category] = (updated[category] ?? 0) + 1;
        state = state.copyWith(exploredCategories: updated);
      }

      // 3. Streak
      state = _updateStreak(state);

      // 4. XP delta from the action itself
      var xpDelta = action.xp;
      if (action == GamificationAction.journalEntry && withFoodPairing) {
        xpDelta += GamificationAction.pairing.xp;
      }

      // 5. Badge awards (each gives bonus XP)
      final newBadges = state.copyWith(xp: state.xp + xpDelta).checkNewBadges();
      final newBadgeIds = [
        ...state.earnedBadgeIds,
        ...newBadges.map((b) => b.id),
      ];
      final badgeXp = newBadges.fold<int>(0, (sum, b) => sum + b.xpReward);

      // 6. Level recompute
      final newXp = state.xp + xpDelta + badgeXp;
      final newLevel = _levelForXp(newXp);

      final next = state.copyWith(
        xp: newXp,
        level: newLevel,
        earnedBadgeIds: newBadgeIds,
      );

      tx.set(ref, next.toMap());
    });
  }

  GamificationState _updateStreak(GamificationState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      state.lastActiveDate.year,
      state.lastActiveDate.month,
      state.lastActiveDate.day,
    );
    final daysSince = today.difference(last).inDays;

    final newStreak = switch (daysSince) {
      0 => state.streak == 0 ? 1 : state.streak, // first action ever
      1 => state.streak + 1,
      _ => 1, // gap → reset
    };

    return state.copyWith(
      streak: newStreak,
      lastActiveDate: today,
    );
  }

  int _levelForXp(int xp) {
    // kXpLevels keyed by level → minXp. Find highest level whose
    // minXp <= xp.
    var level = 0;
    for (var l = 0; l <= 3; l++) {
      final tier = _kXpLevels[l];
      if (tier != null && xp >= tier) level = l;
    }
    return level;
  }

  // Mirror of pairing_constants kXpLevels[level].minXp — kept inline
  // to avoid a public coupling. Update if kXpLevels changes.
  static const _kXpLevels = <int, int>{
    0: 0,
    1: 250,
    2: 1000,
    3: 3000,
  };
}

final gamificationServiceProvider = Provider<GamificationService>(
  (_) => GamificationService(FirebaseFirestore.instance, FirebaseAuth.instance),
);
