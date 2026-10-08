import 'package:flutter/material.dart';
import 'package:winebro/core/config/app_config.dart';

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

  /// Parses `{type, value}` as stored in `config/badges`.
  factory BadgeCondition.fromMap(Map<String, dynamic> m) {
    final value = m['value'];
    final n = value is num ? value.toInt() : 0;
    return switch (m['type']) {
      'scanCount' => ScanCountCondition(n),
      'journalCount' => JournalCountCondition(n),
      'pairingCount' => PairingCountCondition(n),
      'streakDays' => StreakCondition(n),
      'categoryExplored' => CategoryExploredCondition(value.toString()),
      'challengeCount' => ChallengeCountCondition(n),
      'special' => SpecialCondition(value.toString()),
      _ => throw FormatException('unknown badge condition ${m['type']}'),
    };
  }

  Map<String, Object> toMap() => switch (this) {
        ScanCountCondition(:final count) => {'type': 'scanCount', 'value': count},
        JournalCountCondition(:final count) => {'type': 'journalCount', 'value': count},
        PairingCountCondition(:final count) => {'type': 'pairingCount', 'value': count},
        StreakCondition(:final days) => {'type': 'streakDays', 'value': days},
        CategoryExploredCondition(:final category) => {'type': 'categoryExplored', 'value': category},
        ChallengeCountCondition(:final count) => {'type': 'challengeCount', 'value': count},
        SpecialCondition(:final key) => {'type': 'special', 'value': key},
      };
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

/// All badges, from `config/badges`.
List<Badge> get kBadges => AppConfig.current.badges.items;

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

  ({String name, int minXp, IconData icon}) get levelInfo {
    final l = AppConfig.current.gamification.levelInfo(level);
    return (name: l.name, minXp: l.minXp, icon: l.icon);
  }

  int? get xpForNextLevel =>
      AppConfig.current.gamification.minXpForLevel(level + 1);

  double get levelProgress {
    final nextXp = xpForNextLevel;
    if (nextXp == null) return 1.0;
    final currentMin = levelInfo.minXp;
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
    'max-level' =>
        level >= AppConfig.current.gamification.levels.last.level,
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

