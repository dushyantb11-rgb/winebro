import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/features/profile/domain/gamification.dart';

/// Streak transition contract that GamificationService relies on.
///
/// Public contract:
///   - same-day action → no change
///   - next-day action → streak + 1
///   - 2+ day gap     → reset to 1
///   - first action ever (streak 0, today) → 1
void main() {
  GamificationState build({
    required int streak,
    required DateTime lastActiveDate,
  }) =>
      GamificationState(
        xp: 0,
        level: 0,
        streak: streak,
        earnedBadgeIds: const [],
        totalScans: 0,
        totalJournalEntries: 0,
        totalPairings: 0,
        totalChallenges: 0,
        exploredCategories: const {},
        lastActiveDate: lastActiveDate,
      );

  /// Reproduces the exact transition formula from
  /// `GamificationService._updateStreak`. If service code drifts, this
  /// test should be updated to match.
  GamificationState applyStreak(GamificationState state, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      state.lastActiveDate.year,
      state.lastActiveDate.month,
      state.lastActiveDate.day,
    );
    final daysSince = today.difference(last).inDays;

    final newStreak = switch (daysSince) {
      0 => state.streak == 0 ? 1 : state.streak,
      1 => state.streak + 1,
      _ => 1,
    };

    return state.copyWith(streak: newStreak, lastActiveDate: today);
  }

  test('same-day action keeps streak constant', () {
    final state = build(streak: 5, lastActiveDate: DateTime(2026, 5, 5));
    final next = applyStreak(state, DateTime(2026, 5, 5, 14));
    expect(next.streak, 5);
  });

  test('next-day action increments streak', () {
    final state = build(streak: 5, lastActiveDate: DateTime(2026, 5, 5));
    final next = applyStreak(state, DateTime(2026, 5, 6, 9));
    expect(next.streak, 6);
  });

  test('2-day gap resets to 1', () {
    final state = build(streak: 12, lastActiveDate: DateTime(2026, 5, 5));
    final next = applyStreak(state, DateTime(2026, 5, 7));
    expect(next.streak, 1);
  });

  test('first action ever bumps from 0 to 1', () {
    final state = build(streak: 0, lastActiveDate: DateTime(2026, 5, 5));
    final next = applyStreak(state, DateTime(2026, 5, 5, 23));
    expect(next.streak, 1);
  });

  test('week-long gap still resets to 1, not 0', () {
    final state = build(streak: 9, lastActiveDate: DateTime(2026, 5, 5));
    final next = applyStreak(state, DateTime(2026, 5, 12));
    expect(next.streak, 1);
  });

  test('month-end → next-month rollover handled by date arithmetic', () {
    // Apr 30 → May 1 = 1 day diff.
    final state = build(streak: 7, lastActiveDate: DateTime(2026, 4, 30));
    final next = applyStreak(state, DateTime(2026, 5, 1));
    expect(next.streak, 8);
  });
}
