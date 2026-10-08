import 'dart:convert';

import 'package:flutter/material.dart' hide Badge;
import 'package:winebro/core/config/default_config.g.dart';
import 'package:winebro/core/config/icon_registry.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/aroma_wheel/domain/aroma_taxonomy.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/profile/domain/gamification.dart';

/// Every rule set and reference list the app runs on, loaded from
/// Firestore `config/{doc}` with the bundled JSON as fallback.
///
/// Engines read [AppConfig.current]; the admin web app edits the
/// Firestore documents. Codes (enum names, ids) are stable identifiers;
/// everything about them — names, thresholds, points, texts, icons,
/// lists — comes from here.
class AppConfig {
  const AppConfig({
    required this.pairingRules,
    required this.archetypes,
    required this.quiz,
    required this.scanner,
    required this.gamification,
    required this.badges,
    required this.categories,
    required this.occasions,
    required this.journalScales,
    required this.aromaWheel,
    required this.home,
    required this.notifications,
    this.versions = const {},
  });

  final PairingRulesConfig pairingRules;
  final ArchetypesConfig archetypes;
  final QuizConfig quiz;
  final ScannerConfig scanner;
  final GamificationConfig gamification;
  final BadgesConfig badges;
  final CategoriesConfig categories;
  final OccasionsConfig occasions;
  final JournalScalesConfig journalScales;
  final AromaWheelConfig aromaWheel;
  final HomeConfig home;
  final NotificationsConfig notifications;

  /// Firestore `version` per document; empty for the bundled defaults.
  final Map<String, int> versions;

  /// The bundled copy of the config, used before Firestore answers.
  static final AppConfig defaults = AppConfig.fromJson(
    jsonDecode(kDefaultConfigJson) as Map<String, dynamic>,
  );

  /// The config in force right now. Replaced whenever Firestore delivers
  /// a new snapshot; never null.
  static AppConfig current = defaults;

  /// Builds a config from `{docId: docData}`. A document that is missing
  /// or fails to parse falls back to the same document in [fallback]
  /// (or the bundled defaults) and reports through [onError].
  factory AppConfig.fromJson(
    Map<String, dynamic> json, {
    AppConfig? fallback,
    void Function(String doc, Object error, StackTrace stack)? onError,
  }) {
    T doc<T>(String id, T Function(Map<String, dynamic>) parse, T? backup) {
      final raw = json[id];
      if (raw is! Map) {
        if (backup != null) return backup;
        throw FormatException('config/$id missing');
      }
      try {
        return parse(Map<String, dynamic>.from(raw));
      } catch (e, s) {
        onError?.call(id, e, s);
        if (backup != null) return backup;
        rethrow;
      }
    }

    final versions = <String, int>{
      for (final e in json.entries)
        if (e.value is Map && (e.value as Map)['version'] is int)
          e.key: (e.value as Map)['version'] as int,
    };
    return AppConfig(
      pairingRules: doc('pairingRules', PairingRulesConfig.fromMap, fallback?.pairingRules),
      archetypes: doc('archetypes', ArchetypesConfig.fromMap, fallback?.archetypes),
      quiz: doc('quiz', QuizConfig.fromMap, fallback?.quiz),
      scanner: doc('scanner', ScannerConfig.fromMap, fallback?.scanner),
      gamification: doc('gamification', GamificationConfig.fromMap, fallback?.gamification),
      badges: doc('badges', BadgesConfig.fromMap, fallback?.badges),
      categories: doc('categories', CategoriesConfig.fromMap, fallback?.categories),
      occasions: doc('occasions', OccasionsConfig.fromMap, fallback?.occasions),
      journalScales: doc('journalScales', JournalScalesConfig.fromMap, fallback?.journalScales),
      aromaWheel: doc('aromaWheel', AromaWheelConfig.fromMap, fallback?.aromaWheel),
      home: doc('home', HomeConfig.fromMap, fallback?.home),
      notifications: doc('notifications', NotificationsConfig.fromMap, fallback?.notifications),
      versions: versions,
    );
  }
}

// ─── Parsing helpers ─────────────────────────────────────────────

T? _enumByName<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

double _num(Map<String, dynamic> m, String key, [double? fallback]) {
  final v = m[key];
  if (v is num) return v.toDouble();
  if (fallback != null) return fallback;
  throw FormatException('$key must be a number');
}

int _int(Map<String, dynamic> m, String key, [int? fallback]) {
  final v = m[key];
  if (v is num) return v.toInt();
  if (fallback != null) return fallback;
  throw FormatException('$key must be a number');
}

String _str(Map<String, dynamic> m, String key, [String? fallback]) {
  final v = m[key];
  if (v is String) return v;
  if (fallback != null) return fallback;
  throw FormatException('$key must be text');
}

List<Map<String, dynamic>> _maps(Object? v) => [
      for (final e in (v as List?) ?? const [])
        if (e is Map) Map<String, dynamic>.from(e),
    ];

List<String> _strings(Object? v) =>
    [for (final e in (v as List?) ?? const []) if (e is String) e];

// ─── Conditions and rules ────────────────────────────────────────

/// `axis op value`, e.g. `acidity >= 6`.
class AxisCondition {
  const AxisCondition(this.axis, this.op, this.value);

  final PalateAxis axis;
  final String op;
  final double value;

  factory AxisCondition.fromMap(Map<String, dynamic> m) {
    final axis = _enumByName(PalateAxis.values, m['axis']);
    if (axis == null) throw FormatException('unknown axis ${m['axis']}');
    return AxisCondition(axis, _str(m, 'op'), _num(m, 'value'));
  }

  static List<AxisCondition> listFrom(Object? v) =>
      [for (final m in _maps(v)) AxisCondition.fromMap(m)];

  bool holds(double actual) => switch (op) {
        '>=' => actual >= value,
        '<=' => actual <= value,
        '>' => actual > value,
        '<' => actual < value,
        '==' => actual == value,
        _ => false,
      };

  Map<String, Object> toMap() => {'axis': axis.name, 'op': op, 'value': value};
}

/// True when every condition holds for the values [read] gives.
bool allHold(List<AxisCondition> when, double Function(PalateAxis) read) =>
    when.every((c) => c.holds(read(c.axis)));

/// Points given when all [when] conditions hold.
class PointsRule {
  const PointsRule(this.when, this.points);
  final List<AxisCondition> when;
  final double points;

  factory PointsRule.fromMap(Map<String, dynamic> m) =>
      PointsRule(AxisCondition.listFrom(m['when']), _num(m, 'points'));
}

class StrategyIndicator {
  const StrategyIndicator(this.property, this.when);
  final FoodProperty property;
  final List<AxisCondition> when;
}

class WhyVariant {
  const WhyVariant(this.when, this.text);
  final List<AxisCondition> when;
  final String text;
}

/// Bro-tip template. Placeholders: {dish} {drink} {strategy} {why}.
class ExplanationTemplate {
  const ExplanationTemplate({
    required this.strategy,
    required this.property,
    required this.text,
    this.why = const [],
  });

  final PairingStrategy strategy;
  final FoodProperty property;
  final String text;
  final List<WhyVariant> why;
}

class PairingRulesConfig {
  const PairingRulesConfig({
    required this.axisWeights,
    required this.scoreFloor,
    required this.scoreCeiling,
    required this.foodWeight,
    required this.curatedBonus,
    required this.feedbackBiasCapPoints,
    required this.frequencyPenaltySecond,
    required this.frequencyPenaltyThird,
    required this.frequencyPenaltyCap,
    required this.foodFitBase,
    required this.foodFitRules,
    required this.contrastIndicators,
    required this.complementIndicators,
    required this.explanations,
    required this.explanationDefault,
  });

  final Map<PalateAxis, double> axisWeights;
  final double scoreFloor;
  final double scoreCeiling;
  final double foodWeight;
  final double curatedBonus;
  final double feedbackBiasCapPoints;
  final double frequencyPenaltySecond;
  final double frequencyPenaltyThird;
  final double frequencyPenaltyCap;
  final double foodFitBase;
  final Map<FoodProperty, List<PointsRule>> foodFitRules;
  final List<StrategyIndicator> contrastIndicators;
  final List<StrategyIndicator> complementIndicators;
  final List<ExplanationTemplate> explanations;
  final String explanationDefault;

  factory PairingRulesConfig.fromMap(Map<String, dynamic> m) {
    final weights = Map<String, dynamic>.from(m['axisWeights'] as Map? ?? {});
    final penalty = Map<String, dynamic>.from(m['frequencyPenalty'] as Map? ?? {});
    final rulesRaw = Map<String, dynamic>.from(m['foodFitRules'] as Map? ?? {});
    final indicators = Map<String, dynamic>.from(m['strategyIndicators'] as Map? ?? {});

    List<StrategyIndicator> ind(Object? v) => [
          for (final e in _maps(v))
            if (_enumByName(FoodProperty.values, e['property']) case final p?)
              StrategyIndicator(p, AxisCondition.listFrom(e['when'])),
        ];

    return PairingRulesConfig(
      axisWeights: {
        for (final a in PalateAxis.values)
          a: (weights[a.name] as num?)?.toDouble() ?? 1.0,
      },
      scoreFloor: _num(m, 'scoreFloor'),
      scoreCeiling: _num(m, 'scoreCeiling'),
      foodWeight: _num(m, 'foodWeight'),
      curatedBonus: _num(m, 'curatedBonus'),
      feedbackBiasCapPoints: _num(m, 'feedbackBiasCapPoints'),
      frequencyPenaltySecond: _num(penalty, 'second'),
      frequencyPenaltyThird: _num(penalty, 'third'),
      frequencyPenaltyCap: _num(penalty, 'cap'),
      foodFitBase: _num(m, 'foodFitBase', 50),
      foodFitRules: {
        for (final e in rulesRaw.entries)
          if (_enumByName(FoodProperty.values, e.key) case final p?)
            p: [for (final r in _maps(e.value)) PointsRule.fromMap(r)],
      },
      contrastIndicators: ind(indicators['contrast']),
      complementIndicators: ind(indicators['complement']),
      explanations: [
        for (final e in _maps(m['explanations']))
          if (_enumByName(PairingStrategy.values, e['strategy']) case final s?)
            if (_enumByName(FoodProperty.values, e['property']) case final p?)
              ExplanationTemplate(
                strategy: s,
                property: p,
                text: _str(e, 'text'),
                why: [
                  for (final w in _maps(e['why']))
                    WhyVariant(AxisCondition.listFrom(w['when']), _str(w, 'text')),
                ],
              ),
      ],
      explanationDefault: _str(m, 'explanationDefault'),
    );
  }
}

// ─── Archetypes ──────────────────────────────────────────────────

class ArchetypeInfo {
  const ArchetypeInfo({
    required this.displayName,
    required this.description,
    required this.iconName,
    required this.bonusPercent,
  });

  final String displayName;
  final String description;
  final String iconName;
  final int bonusPercent;

  IconData get icon => iconFor(iconName, fallback: Icons.wine_bar);
}

class ArchetypeRule {
  const ArchetypeRule({
    required this.archetype,
    this.when = const [],
    this.allAxesMin,
    this.allAxesMax,
    this.rankSum = const [],
    this.rankSumInverted = const [],
    this.lowVariance,
  });

  final PalateArchetype archetype;
  final List<AxisCondition> when;
  final double? allAxesMin;
  final double? allAxesMax;
  final List<PalateAxis> rankSum;
  final List<PalateAxis> rankSumInverted;

  /// When set, rank = lowVariance - variance of all axes.
  final double? lowVariance;

  factory ArchetypeRule.fromMap(Map<String, dynamic> m) {
    final archetype = _enumByName(PalateArchetype.values, m['archetype']);
    if (archetype == null) {
      throw FormatException('unknown archetype ${m['archetype']}');
    }
    final all = m['allAxes'] is Map ? Map<String, dynamic>.from(m['allAxes'] as Map) : null;
    final rank = m['rank'] is Map ? Map<String, dynamic>.from(m['rank'] as Map) : const <String, dynamic>{};
    List<PalateAxis> axes(Object? v) => [
          for (final s in _strings(v))
            if (_enumByName(PalateAxis.values, s) case final a?) a,
        ];
    return ArchetypeRule(
      archetype: archetype,
      when: AxisCondition.listFrom(m['when']),
      allAxesMin: all == null ? null : _num(all, 'min'),
      allAxesMax: all == null ? null : _num(all, 'max'),
      rankSum: axes(rank['sum']),
      rankSumInverted: axes(rank['sumInverted']),
      lowVariance: (rank['lowVariance'] as num?)?.toDouble(),
    );
  }

  /// Rank when the profile qualifies, otherwise null.
  double? rank(Map<PalateAxis, double> scores, double axisMax) {
    if (!allHold(when, (a) => scores[a] ?? 0)) return null;
    if (allAxesMin != null || allAxesMax != null) {
      final ok = scores.values.every(
        (v) => v >= (allAxesMin ?? double.negativeInfinity) && v <= (allAxesMax ?? double.infinity),
      );
      if (!ok) return null;
    }
    var r = 0.0;
    for (final a in rankSum) {
      r += scores[a] ?? 0;
    }
    for (final a in rankSumInverted) {
      r += axisMax - (scores[a] ?? 0);
    }
    if (lowVariance != null) {
      final values = scores.values.toList();
      final mean = values.fold(0.0, (s, v) => s + v) / values.length;
      final variance =
          values.fold(0.0, (s, v) => s + (v - mean) * (v - mean)) / values.length;
      r += lowVariance! - variance;
    }
    return r;
  }
}

class ArchetypesConfig {
  const ArchetypesConfig({
    required this.items,
    required this.rules,
    required this.fallback,
  });

  final Map<PalateArchetype, ArchetypeInfo> items;
  final List<ArchetypeRule> rules;
  final PalateArchetype fallback;

  factory ArchetypesConfig.fromMap(Map<String, dynamic> m) => ArchetypesConfig(
        items: {
          for (final e in _maps(m['items']))
            if (_enumByName(PalateArchetype.values, e['code']) case final a?)
              a: ArchetypeInfo(
                displayName: _str(e, 'displayName'),
                description: _str(e, 'description', ''),
                iconName: _str(e, 'icon', 'wine_bar'),
                bonusPercent: _int(e, 'bonusPercent', 0),
              ),
        },
        rules: [for (final r in _maps(m['rules'])) ArchetypeRule.fromMap(r)],
        fallback: _enumByName(PalateArchetype.values, m['fallback']) ??
            PalateArchetype.balancedSipper,
      );
}

// ─── Quiz ────────────────────────────────────────────────────────

class QuizAnswer {
  const QuizAnswer({
    required this.id,
    required this.label,
    required this.icon,
    required this.axisContributions,
  });

  final String id;
  final String label;
  final IconData icon;
  final Map<PalateAxis, double> axisContributions;

  factory QuizAnswer.fromMap(Map<String, dynamic> m) {
    final axes = Map<String, dynamic>.from(m['axes'] as Map? ?? {});
    return QuizAnswer(
      id: _str(m, 'id'),
      label: _str(m, 'label'),
      icon: iconFor(m['icon'] as String?, fallback: Icons.restaurant),
      axisContributions: {
        for (final e in axes.entries)
          if (_enumByName(PalateAxis.values, e.key) case final a?)
            if (e.value is num) a: (e.value as num).toDouble(),
      },
    );
  }
}

class QuizStep {
  const QuizStep({
    required this.id,
    required this.multi,
    required this.optional,
    required this.answers,
  });

  final String id;
  final bool multi;
  final bool optional;
  final List<QuizAnswer> answers;
}

class QuizConfig {
  const QuizConfig({
    required this.axisMin,
    required this.axisMax,
    required this.quizBlendWeight,
    required this.sliderBlendWeight,
    required this.triedPriorWeight,
    required this.steps,
  });

  final double axisMin;
  final double axisMax;
  final double quizBlendWeight;
  final double sliderBlendWeight;
  final double triedPriorWeight;
  final List<QuizStep> steps;

  /// Answers of the step with this id; empty when the step is missing.
  List<QuizAnswer> answers(String stepId) =>
      steps.where((s) => s.id == stepId).firstOrNull?.answers ?? const [];

  factory QuizConfig.fromMap(Map<String, dynamic> m) => QuizConfig(
        axisMin: _num(m, 'axisMin', 0),
        axisMax: _num(m, 'axisMax', 10),
        quizBlendWeight: _num(m, 'quizBlendWeight'),
        sliderBlendWeight: _num(m, 'sliderBlendWeight'),
        triedPriorWeight: _num(m, 'triedPriorWeight'),
        steps: [
          for (final s in _maps(m['steps']))
            QuizStep(
              id: _str(s, 'id'),
              multi: s['multi'] == true,
              optional: s['optional'] == true,
              answers: [for (final a in _maps(s['answers'])) QuizAnswer.fromMap(a)],
            ),
        ],
      );
}

// ─── Scanner ─────────────────────────────────────────────────────

class ScannerConfig {
  const ScannerConfig({
    required this.minScore,
    required this.fuzzyThreshold,
    required this.minFuzzyWordLength,
    required this.genericWords,
  });

  final double minScore;
  final double fuzzyThreshold;
  final int minFuzzyWordLength;
  final Set<String> genericWords;

  factory ScannerConfig.fromMap(Map<String, dynamic> m) => ScannerConfig(
        minScore: _num(m, 'minScore'),
        fuzzyThreshold: _num(m, 'fuzzyThreshold'),
        minFuzzyWordLength: _int(m, 'minFuzzyWordLength', 4),
        genericWords: _strings(m['genericWords']).toSet(),
      );
}

// ─── Gamification ────────────────────────────────────────────────

typedef LevelInfo = ({int level, String name, int minXp, IconData icon});

class GamificationConfig {
  const GamificationConfig({required this.actions, required this.levels});

  /// XP per action code (`scan`, `journalEntry`, `pairing`).
  final Map<String, int> actions;

  /// Levels sorted by minXp, level 0 first.
  final List<LevelInfo> levels;

  int xpFor(String action) => actions[action] ?? 0;

  LevelInfo levelInfo(int level) =>
      levels.where((l) => l.level == level).firstOrNull ?? levels.first;

  int? minXpForLevel(int level) =>
      levels.where((l) => l.level == level).firstOrNull?.minXp;

  int levelForXp(int xp) {
    var best = levels.first.level;
    for (final l in levels) {
      if (xp >= l.minXp && l.level > best) best = l.level;
    }
    return best;
  }

  factory GamificationConfig.fromMap(Map<String, dynamic> m) {
    final actions = Map<String, dynamic>.from(m['actions'] as Map? ?? {});
    final levels = [
      for (final l in _maps(m['levels']))
        (
          level: _int(l, 'level'),
          name: _str(l, 'name'),
          minXp: _int(l, 'minXp'),
          icon: iconFor(l['icon'] as String?, fallback: Icons.eco),
        ),
    ]..sort((a, b) => a.minXp.compareTo(b.minXp));
    if (levels.isEmpty) throw const FormatException('levels must not be empty');
    return GamificationConfig(
      actions: {
        for (final e in actions.entries)
          if (e.value is num) e.key: (e.value as num).toInt(),
      },
      levels: levels,
    );
  }
}

class BadgesConfig {
  const BadgesConfig({required this.items});
  final List<Badge> items;

  factory BadgesConfig.fromMap(Map<String, dynamic> m) => BadgesConfig(
        items: [
          for (final b in _maps(m['items']))
            Badge(
              id: _str(b, 'id'),
              name: _str(b, 'name'),
              description: _str(b, 'description', ''),
              icon: iconFor(b['icon'] as String?, fallback: Icons.military_tech),
              xpReward: _int(b, 'xpReward', 0),
              condition: BadgeCondition.fromMap(
                Map<String, dynamic>.from(b['condition'] as Map? ?? {}),
              ),
            ),
        ],
      );
}

// ─── Reference lists ─────────────────────────────────────────────

class DrinkCategoryInfo {
  const DrinkCategoryInfo({required this.displayName, required this.group});
  final String displayName;
  final String group;
}

class DrinkGroupInfo {
  const DrinkGroupInfo({required this.name, required this.image});
  final String name;
  final String image;
}

class CuisineInfo {
  const CuisineInfo({required this.displayName, required this.iconName});
  final String displayName;
  final String iconName;
  IconData get icon => iconFor(iconName, fallback: Icons.restaurant);
}

class StrategyInfo {
  const StrategyInfo({required this.displayName, required this.description});
  final String displayName;
  final String description;
}

class CategoriesConfig {
  const CategoriesConfig({
    required this.palateAxes,
    required this.drinkGroups,
    required this.drinks,
    required this.cuisines,
    required this.foodProperties,
    required this.pairingStrategies,
  });

  final Map<PalateAxis, String> palateAxes;
  final List<DrinkGroupInfo> drinkGroups;
  final Map<DrinkCategory, DrinkCategoryInfo> drinks;
  final Map<FoodCategory, CuisineInfo> cuisines;
  final Map<FoodProperty, String> foodProperties;
  final Map<PairingStrategy, StrategyInfo> pairingStrategies;

  String? drinkGroupImage(String group) =>
      drinkGroups.where((g) => g.name == group).firstOrNull?.image;

  factory CategoriesConfig.fromMap(Map<String, dynamic> m) => CategoriesConfig(
        palateAxes: {
          for (final e in _maps(m['palateAxes']))
            if (_enumByName(PalateAxis.values, e['code']) case final a?)
              a: _str(e, 'displayName'),
        },
        drinkGroups: [
          for (final g in _maps(m['drinkGroups']))
            DrinkGroupInfo(name: _str(g, 'name'), image: _str(g, 'image')),
        ],
        drinks: {
          for (final e in _maps(m['drinks']))
            if (_enumByName(DrinkCategory.values, e['code']) case final c?)
              c: DrinkCategoryInfo(
                displayName: _str(e, 'displayName'),
                group: _str(e, 'group'),
              ),
        },
        cuisines: {
          for (final e in _maps(m['cuisines']))
            if (_enumByName(FoodCategory.values, e['code']) case final c?)
              c: CuisineInfo(
                displayName: _str(e, 'displayName'),
                iconName: _str(e, 'icon', 'restaurant'),
              ),
        },
        foodProperties: {
          for (final e in _maps(m['foodProperties']))
            if (_enumByName(FoodProperty.values, e['code']) case final p?)
              p: _str(e, 'displayName'),
        },
        pairingStrategies: {
          for (final e in _maps(m['pairingStrategies']))
            if (_enumByName(PairingStrategy.values, e['code']) case final s?)
              s: StrategyInfo(
                displayName: _str(e, 'displayName'),
                description: _str(e, 'description', ''),
              ),
        },
      );
}

class OccasionInfo {
  const OccasionInfo({
    required this.displayName,
    required this.iconName,
    required this.axisModifiers,
    this.categoryBonus,
  });

  final String displayName;
  final String iconName;
  final Map<PalateAxis, double> axisModifiers;
  final ({DrinkCategory category, double bonusPercent})? categoryBonus;

  IconData get icon => iconFor(iconName, fallback: Icons.celebration);
}

class OccasionsConfig {
  const OccasionsConfig({required this.items});
  final Map<Occasion, OccasionInfo> items;

  factory OccasionsConfig.fromMap(Map<String, dynamic> m) => OccasionsConfig(
        items: {
          for (final e in _maps(m['items']))
            if (_enumByName(Occasion.values, e['code']) case final o?)
              o: OccasionInfo(
                displayName: _str(e, 'displayName'),
                iconName: _str(e, 'icon', 'celebration'),
                axisModifiers: {
                  for (final a in Map<String, dynamic>.from(
                    e['axisModifiers'] as Map? ?? {},
                  ).entries)
                    if (_enumByName(PalateAxis.values, a.key) case final axis?)
                      if (a.value is num) axis: (a.value as num).toDouble(),
                },
                categoryBonus: switch (e['categoryBonus']) {
                  final Map b when _enumByName(
                        DrinkCategory.values,
                        b['category'],
                      ) !=
                      null =>
                    (
                      category: _enumByName(DrinkCategory.values, b['category'])!,
                      bonusPercent: ((b['bonusPercent'] as num?) ?? 0).toDouble(),
                    ),
                  _ => null,
                },
              ),
        },
      );
}

class JournalScalesConfig {
  const JournalScalesConfig({required this.scales, required this.ratingMax});
  final Map<String, List<String>> scales;
  final int ratingMax;

  factory JournalScalesConfig.fromMap(Map<String, dynamic> m) => JournalScalesConfig(
        scales: {
          for (final e in m.entries)
            if (e.value is List) e.key: _strings(e.value),
        },
        ratingMax: _int(m, 'ratingMax', 5),
      );
}

class AromaWheelConfig {
  const AromaWheelConfig({
    required this.categories,
    required this.desiTerms,
    required this.calibrationCount,
    required this.indianShare,
  });

  final List<AromaCategory> categories;
  final Set<String> desiTerms;
  final int calibrationCount;
  final double indianShare;

  factory AromaWheelConfig.fromMap(Map<String, dynamic> m) {
    final cal = Map<String, dynamic>.from(m['calibration'] as Map? ?? {});
    int colour(String hex) {
      final h = hex.replaceFirst('#', '');
      return int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
    }
    return AromaWheelConfig(
      categories: [
        for (final c in _maps(m['categories']))
          AromaCategory(
            name: _str(c, 'name'),
            color: colour(_str(c, 'color', '#93003C')),
            subcategories: [
              for (final s in _maps(c['subcategories']))
                AromaSubcategory(name: _str(s, 'name'), aromas: _strings(s['aromas'])),
            ],
          ),
      ],
      desiTerms: _strings(m['desiTerms']).toSet(),
      calibrationCount: _int(cal, 'count', 3),
      indianShare: _num(cal, 'indianShare', 2 / 3),
    );
  }
}

class EmotionTileConfig {
  const EmotionTileConfig({
    required this.id,
    required this.labelKey,
    required this.iconName,
    required this.gradient,
    required this.route,
  });

  final String id;
  final String labelKey;
  final String iconName;

  /// Two palette token names, e.g. `paprika`, `thunderLight`.
  final List<String> gradient;
  final String route;

  IconData get icon => iconFor(iconName, fallback: Icons.local_bar);
}

class HomeConfig {
  const HomeConfig({required this.emotionTiles, required this.logo});
  final List<EmotionTileConfig> emotionTiles;
  final String logo;

  factory HomeConfig.fromMap(Map<String, dynamic> m) => HomeConfig(
        emotionTiles: [
          for (final t in _maps(m['emotionTiles']))
            EmotionTileConfig(
              id: _str(t, 'id'),
              labelKey: _str(t, 'labelKey'),
              iconName: _str(t, 'icon', 'local_bar'),
              gradient: _strings(t['gradient']),
              route: _str(t, 'route', '/pair'),
            ),
        ],
        logo: _str(m, 'logo', 'assets/images/logo.png'),
      );
}

class NotificationsConfig {
  const NotificationsConfig({required this.deepLinks});

  /// Deep link per notification type code.
  final Map<String, String> deepLinks;

  factory NotificationsConfig.fromMap(Map<String, dynamic> m) => NotificationsConfig(
        deepLinks: {
          for (final t in _maps(m['types'])) _str(t, 'code'): _str(t, 'deepLink', '/'),
        },
      );
}
