import 'package:flutter/material.dart';
import 'package:winebro/core/constants/pairing_constants.dart';

class Badge {
  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.condition,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int xpReward;
  final BadgeCondition condition;
}

sealed class BadgeCondition {
  const BadgeCondition();
}

final class ScanCountCondition extends BadgeCondition {
  const ScanCountCondition(this.count);
  final int count;
}

final class JournalCountCondition extends BadgeCondition {
  const JournalCountCondition(this.count);
  final int count;
}

final class PairingCountCondition extends BadgeCondition {
  const PairingCountCondition(this.count);
  final int count;
}

final class StreakCondition extends BadgeCondition {
  const StreakCondition(this.days);
  final int days;
}

final class CategoryExploredCondition extends BadgeCondition {
  const CategoryExploredCondition(this.category);
  final String category;
}

final class ChallengeCountCondition extends BadgeCondition {
  const ChallengeCountCondition(this.count);
  final int count;
}

final class SpecialCondition extends BadgeCondition {
  const SpecialCondition(this.key);
  final String key;
}

const kBadges = <Badge>[
  Badge(
    id: 'first-scan',
    name: 'Eagle Eye',
    description: 'Scanned your first bottle',
    icon: Icons.visibility,
    xpReward: 50,
    condition: ScanCountCondition(1),
  ),
  Badge(
    id: 'scan-master',
    name: 'Scan Master',
    description: 'Scanned 50 bottles',
    icon: Icons.photo_camera,
    xpReward: 200,
    condition: ScanCountCondition(50),
  ),
  Badge(
    id: 'first-note',
    name: 'The Pen',
    description: 'Wrote your first tasting note',
    icon: Icons.edit,
    xpReward: 50,
    condition: JournalCountCondition(1),
  ),
  Badge(
    id: 'journal-10',
    name: 'Sommelier in Training',
    description: 'Logged 10 tastings',
    icon: Icons.menu_book,
    xpReward: 100,
    condition: JournalCountCondition(10),
  ),
  Badge(
    id: 'journal-50',
    name: 'Dedicated Taster',
    description: 'Logged 50 tastings',
    icon: Icons.emoji_events,
    xpReward: 500,
    condition: JournalCountCondition(50),
  ),
  Badge(
    id: 'first-pair',
    name: 'Matchmaker',
    description: 'Found your first perfect pairing',
    icon: Icons.handshake,
    xpReward: 50,
    condition: PairingCountCondition(1),
  ),
  Badge(
    id: 'pair-25',
    name: 'Pairing Pro',
    description: 'Discovered 25 food-drink pairings',
    icon: Icons.track_changes,
    xpReward: 200,
    condition: PairingCountCondition(25),
  ),
  Badge(
    id: 'streak-3',
    name: 'Getting Serious',
    description: 'Maintained a 3-day streak',
    icon: Icons.local_fire_department,
    xpReward: 50,
    condition: StreakCondition(3),
  ),
  Badge(
    id: 'streak-7',
    name: 'On Fire',
    description: '7-day streak! Commitment unlocked',
    icon: Icons.whatshot,
    xpReward: 100,
    condition: StreakCondition(7),
  ),
  Badge(
    id: 'streak-30',
    name: 'Iron Will',
    description: '30-day streak — you\'re unstoppable',
    icon: Icons.fitness_center,
    xpReward: 500,
    condition: StreakCondition(30),
  ),
  Badge(
    id: 'red-explorer',
    name: 'Red Explorer',
    description: 'Tried 5 different red wines',
    icon: Icons.wine_bar,
    xpReward: 100,
    condition: CategoryExploredCondition('redWine'),
  ),
  Badge(
    id: 'white-explorer',
    name: 'White Wanderer',
    description: 'Tried 5 different white wines',
    icon: Icons.local_drink,
    xpReward: 100,
    condition: CategoryExploredCondition('whiteWine'),
  ),
  Badge(
    id: 'whisky-explorer',
    name: 'Spirit Guide',
    description: 'Tried 5 different whiskies',
    icon: Icons.local_bar,
    xpReward: 100,
    condition: CategoryExploredCondition('whisky'),
  ),
  Badge(
    id: 'beer-explorer',
    name: 'Hop Head',
    description: 'Tried 5 different beers',
    icon: Icons.sports_bar,
    xpReward: 100,
    condition: CategoryExploredCondition('beer'),
  ),
  Badge(
    id: 'indian-wine',
    name: 'Swadeshi Sipper',
    description: 'Tried 3 Indian wines',
    icon: Icons.flag,
    xpReward: 100,
    condition: SpecialCondition('indian-wine-3'),
  ),
  Badge(
    id: 'challenge-5',
    name: 'Challenger',
    description: 'Completed 5 daily challenges',
    icon: Icons.bolt,
    xpReward: 100,
    condition: ChallengeCountCondition(5),
  ),
  Badge(
    id: 'challenge-25',
    name: 'Challenge Champion',
    description: 'Completed 25 daily challenges',
    icon: Icons.military_tech,
    xpReward: 300,
    condition: ChallengeCountCondition(25),
  ),
  Badge(
    id: 'aroma-master',
    name: 'Nose Knows',
    description: 'Explored all 6 aroma wheel categories',
    icon: Icons.air,
    xpReward: 200,
    condition: SpecialCondition('all-aroma-categories'),
  ),
  Badge(
    id: 'brocard-master',
    name: 'BroCard Master',
    description: 'Completed 10 detailed BroCard tasting sheets',
    icon: Icons.assignment,
    xpReward: 300,
    condition: SpecialCondition('brocard-10'),
  ),
  Badge(
    id: 'wise-elder',
    name: 'Wise Elder',
    description: 'Reached the highest level',
    icon: Icons.diamond,
    xpReward: 1000,
    condition: SpecialCondition('max-level'),
  ),
];

class GamificationState {
  const GamificationState({
    required this.xp,
    required this.level,
    required this.streak,
    required this.earnedBadgeIds,
    required this.totalScans,
    required this.totalJournalEntries,
    required this.totalPairings,
    required this.totalChallenges,
    required this.exploredCategories,
    required this.lastActiveDate,
  });

  final int xp;
  final int level;
  final int streak;
  final List<String> earnedBadgeIds;
  final int totalScans;
  final int totalJournalEntries;
  final int totalPairings;
  final int totalChallenges;
  final Map<String, int> exploredCategories;
  final DateTime lastActiveDate;

  ({String name, int minXp, IconData icon}) get levelInfo =>
      kXpLevels[level] ?? kXpLevels[0]!;

  int? get xpForNextLevel {
    final next = kXpLevels[level + 1];
    return next?.minXp;
  }

  double get levelProgress {
    final nextXp = xpForNextLevel;
    if (nextXp == null) return 1.0;
    final currentMin = kXpLevels[level]!.minXp;
    final range = nextXp - currentMin;
    if (range <= 0) return 1.0;
    return ((xp - currentMin) / range).clamp(0.0, 1.0);
  }

  List<Badge> checkNewBadges() {
    final newBadges = <Badge>[];
    for (final badge in kBadges) {
      if (earnedBadgeIds.contains(badge.id)) continue;
      if (_meetsCondition(badge.condition)) {
        newBadges.add(badge);
      }
    }
    return newBadges;
  }

  bool _meetsCondition(BadgeCondition condition) => switch (condition) {
    ScanCountCondition(:final count) => totalScans >= count,
    JournalCountCondition(:final count) => totalJournalEntries >= count,
    PairingCountCondition(:final count) => totalPairings >= count,
    StreakCondition(:final days) => streak >= days,
    CategoryExploredCondition(:final category) =>
        (exploredCategories[category] ?? 0) >= 5,
    ChallengeCountCondition(:final count) => totalChallenges >= count,
    SpecialCondition(:final key) => _checkSpecial(key),
  };

  bool _checkSpecial(String key) => switch (key) {
    'indian-wine-3' =>
        (exploredCategories['indianWine'] ?? 0) >= 3,
    'all-aroma-categories' =>
        (exploredCategories['aromaCategories'] ?? 0) >= 6,
    'brocard-10' =>
        (exploredCategories['detailedBroCards'] ?? 0) >= 10,
    'max-level' => level >= 3,
    _ => false,
  };

  GamificationState copyWith({
    int? xp,
    int? level,
    int? streak,
    List<String>? earnedBadgeIds,
    int? totalScans,
    int? totalJournalEntries,
    int? totalPairings,
    int? totalChallenges,
    Map<String, int>? exploredCategories,
    DateTime? lastActiveDate,
  }) {
    return GamificationState(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      totalScans: totalScans ?? this.totalScans,
      totalJournalEntries: totalJournalEntries ?? this.totalJournalEntries,
      totalPairings: totalPairings ?? this.totalPairings,
      totalChallenges: totalChallenges ?? this.totalChallenges,
      exploredCategories: exploredCategories ?? this.exploredCategories,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  Map<String, dynamic> toMap() => {
    'xp': xp,
    'level': level,
    'streak': streak,
    'earnedBadgeIds': earnedBadgeIds,
    'totalScans': totalScans,
    'totalJournalEntries': totalJournalEntries,
    'totalPairings': totalPairings,
    'totalChallenges': totalChallenges,
    'exploredCategories': exploredCategories,
    'lastActiveDate': lastActiveDate.toIso8601String(),
  };

  factory GamificationState.fromMap(Map<String, dynamic> map) =>
      GamificationState(
        xp: map['xp'] as int,
        level: map['level'] as int,
        streak: map['streak'] as int,
        earnedBadgeIds: List<String>.unmodifiable(map['earnedBadgeIds'] as List),
        totalScans: map['totalScans'] as int,
        totalJournalEntries: map['totalJournalEntries'] as int,
        totalPairings: map['totalPairings'] as int,
        totalChallenges: map['totalChallenges'] as int,
        exploredCategories: Map.unmodifiable(
          (map['exploredCategories'] as Map).map(
            (k, v) => MapEntry(k as String, (v as num).toInt()),
          ),
        ),
        lastActiveDate: DateTime.parse(map['lastActiveDate'] as String),
      );

  factory GamificationState.initial() => GamificationState(
    xp: 0,
    level: 0,
    streak: 0,
    earnedBadgeIds: const [],
    totalScans: 0,
    totalJournalEntries: 0,
    totalPairings: 0,
    totalChallenges: 0,
    exploredCategories: const {},
    lastActiveDate: DateTime.now(),
  );
}

