import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/features/profile/domain/gamification.dart';

void main() {
  group('PR-02 to PR-10: Gamification System', () {
    test('PR-03: Level 0 = Curious Sibling', () {
      final state = GamificationState.initial();
      expect(state.level, equals(0));
      expect(state.levelInfo.name, equals('Curious Sibling'));
    });

    test('PR-02: XP bar shows correct progress', () {
      final state = GamificationState.initial().copyWith(xp: 250, level: 0);
      // 0 to 500 = 50%
      expect(state.levelProgress, equals(0.5));
    });

    test('PR-07: 750 XP = 25% from L1 to L2', () {
      final state = GamificationState.initial().copyWith(xp: 750, level: 1);
      // L1 starts at 500, L2 at 1500. Range = 1000. 750-500=250. 250/1000=0.25
      expect(state.levelProgress, equals(0.25));
    });

    test('PR-06: Level 3 at max has 100% progress', () {
      final state = GamificationState.initial().copyWith(xp: 6000, level: 3);
      expect(state.xpForNextLevel, isNull);
      expect(state.levelProgress, equals(1.0));
    });

    test('PR-08: Badge Eagle Eye unlocks after 1 scan', () {
      final state = GamificationState.initial().copyWith(totalScans: 1);
      final newBadges = state.checkNewBadges();
      expect(
        newBadges.any((b) => b.id == 'first-scan'),
        isTrue,
        reason: 'Eagle Eye should unlock at 1 scan',
      );
    });

    test('PR-09: Badge On Fire unlocks after 7-day streak', () {
      final state = GamificationState.initial().copyWith(streak: 7);
      final newBadges = state.checkNewBadges();
      expect(
        newBadges.any((b) => b.id == 'streak-7'),
        isTrue,
        reason: 'On Fire should unlock at 7-day streak',
      );
    });

    test('PR-10: Already earned badges not returned again', () {
      final state = GamificationState.initial().copyWith(
        totalScans: 1,
        earnedBadgeIds: ['first-scan'],
      );
      final newBadges = state.checkNewBadges();
      expect(
        newBadges.any((b) => b.id == 'first-scan'),
        isFalse,
        reason: 'Already earned badge should not be returned',
      );
    });

    test('Multiple badges can unlock at once', () {
      final state = GamificationState.initial().copyWith(
        totalScans: 1,
        totalJournalEntries: 1,
        totalPairings: 1,
        streak: 3,
      );
      final newBadges = state.checkNewBadges();
      expect(newBadges.length, greaterThanOrEqualTo(4));
    });
  });
}
