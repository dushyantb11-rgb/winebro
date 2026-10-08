// Writes every rule set and reference list that lives in app code to
// tool/config/config.json (one entry per Firestore `config/{doc}`), and
// the same file to assets/config/defaults.json, which the app bundles as
// its offline fallback.
//
// Run from app/:  flutter test tool/config/export_config_test.dart
// Upload with:    node functions/scripts/seed-config.js --write
//
// Lives outside test/ so the normal `flutter test` run skips it.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/config/icon_registry.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/notifications/notification_types.dart';
import 'package:winebro/features/aroma_wheel/domain/aroma_calibration.dart';
import 'package:winebro/features/aroma_wheel/domain/aroma_taxonomy.dart';
import 'package:winebro/features/journal/domain/journal_entry.dart';
import 'package:winebro/features/onboarding/domain/quiz_engine.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/profile/data/gamification_service.dart';
import 'package:winebro/features/profile/domain/gamification.dart';
import 'package:winebro/features/scanner/domain/label_matcher.dart';

String icon(IconData i) {
  final name = iconName(i);
  if (name == null) throw StateError('icon not in registry: $i');
  return name;
}

Map<String, Object?> cond(String axis, String op, num value) =>
    {'axis': axis, 'op': op, 'value': value};

Map<String, Object?> rule(List<Map<String, Object?>> when, num points) =>
    {'when': when, 'points': points};

void main() {
  test('export app rules and reference lists to JSON', () {
    final pairingRules = {
      'axisWeights': {
        for (final a in PalateAxis.values) a.name: a.defaultWeight,
      },
      'scoreFloor': kScoreFloor,
      'scoreCeiling': kScoreCeiling,
      'foodWeight': kFoodWeight,
      'curatedBonus': kCuratedBonus,
      'feedbackBiasCapPoints': kFeedbackBiasCapPoints,
      'frequencyPenalty': {
        'second': kFrequencyPenalty2nd,
        'third': kFrequencyPenalty3rd,
        'cap': kFrequencyPenaltyCap,
      },
      'foodFitBase': 50,
      // Per food property, rules are tried in order; the first whose
      // conditions all hold gives its points (on the 0-100 scale).
      'foodFitRules': {
        'highFat': [
          rule([cond('acidity', '>=', 6)], 15),
          rule([cond('acidity', '<=', 3)], -10),
        ],
        'spicyHeat': [
          rule([cond('fruit', '>=', 6), cond('tannin', '<=', 4)], 20),
          rule([cond('tannin', '>=', 7)], -15),
        ],
        'highProtein': [
          rule([cond('tannin', '>=', 6)], 15),
        ],
        'lightDelicate': [
          rule([cond('body', '<=', 4)], 15),
          rule([cond('body', '>=', 7)], -15),
        ],
        'sweetDessert': [
          rule([cond('fruit', '>=', 7)], 15),
          rule([cond('tannin', '>=', 6)], -20),
        ],
        'umamiRich': [
          rule([cond('fruit', '>=', 6), cond('tannin', '<=', 4)], 15),
        ],
        'acidic': [
          rule([cond('acidity', '>=', 6)], 12),
          rule([cond('acidity', '<=', 3)], -10),
        ],
        'smokyCharred': [
          rule([cond('complexity', '>=', 6), cond('body', '>=', 5)], 15),
        ],
        'creamy': [
          rule([cond('acidity', '>=', 5)], 10),
        ],
        'tangy': [
          rule([cond('acidity', '>=', 5), cond('freshness', '>=', 5)], 12),
        ],
        'aromatic': [
          rule([cond('complexity', '>=', 5)], 10),
        ],
      },
      // Strategy = contrast when more contrast indicators hold than
      // complement indicators; otherwise complement.
      'strategyIndicators': {
        'contrast': [
          {'property': 'highFat', 'when': [cond('acidity', '>=', 6)]},
          {'property': 'spicyHeat', 'when': [cond('fruit', '>=', 6)]},
          {'property': 'umamiRich', 'when': [cond('fruit', '>=', 6)]},
        ],
        'complement': [
          {'property': 'highProtein', 'when': [cond('tannin', '>=', 6)]},
          {'property': 'lightDelicate', 'when': [cond('body', '<=', 4)]},
          {'property': 'sweetDessert', 'when': [cond('fruit', '>=', 7)]},
          {'property': 'smokyCharred', 'when': [cond('complexity', '>=', 6)]},
          {'property': 'acidic', 'when': [cond('acidity', '>=', 6)]},
        ],
      },
      // First template whose strategy and property match the pairing
      // is used. Placeholders: {dish} {drink} {strategy} {why}.
      'explanations': [
        {
          'strategy': 'contrast',
          'property': 'spicyHeat',
          'text': 'The {dish} brings serious heat, Bro. {drink}\'s {why} '
              'without killing the flavour. Classic contrast pairing.',
          'why': [
            {
              'when': [cond('fruit', '>=', 7), cond('tannin', '<=', 3)],
              'text': 'ripe fruit softens the heat',
            },
            {
              'when': [cond('acidity', '>=', 6)],
              'text': 'crisp acidity and fresh fruit cool the spice',
            },
            {
              'when': <Object>[],
              'text': 'soft tannins keep the chilli from turning bitter',
            },
          ],
        },
        {
          'strategy': 'contrast',
          'property': 'highFat',
          'text': 'Rich, creamy {dish} needs a palate cleanser. {drink}\'s '
              'bright acidity cuts through the richness like a charm. '
              'Your mouth stays fresh.',
        },
        {
          'strategy': 'contrast',
          'property': 'umamiRich',
          'text': '{dish} is packed with umami depth. {drink}\'s '
              'fruit-forward character provides the contrast your palate '
              'craves. Beautiful balance.',
        },
        {
          'strategy': 'complement',
          'property': 'smokyCharred',
          'text': 'Smoke meets smoke, Bro. {dish}\'s charred notes find a '
              'soulmate in {drink}\'s complex, oak-aged character. They '
              'amplify each other.',
        },
        {
          'strategy': 'complement',
          'property': 'highProtein',
          'text': '{dish}\'s protein is the perfect dance partner for '
              '{drink}\'s tannins. The tannin binds to protein and softens '
              '— making the wine taste smoother.',
        },
        {
          'strategy': 'complement',
          'property': 'lightDelicate',
          'text': 'Delicate {dish} needs a gentle companion. {drink}\'s '
              'light body won\'t overpower the subtle flavours. '
              'Weight-matching at its finest.',
        },
      ],
      'explanationDefault': '{drink} and {dish} are a solid match. The '
          '{strategy} pairing brings out the best in both — trust your Bro '
          'on this one.',
    };

    final archetypes = {
      'fallback': PalateArchetype.balancedSipper.name,
      'items': [
        for (final a in PalateArchetype.values)
          {
            'code': a.name,
            'displayName': a.displayName,
            'description': a.description,
            'icon': icon(a.icon),
            'bonusPercent': a.bonusPercent,
          },
      ],
      // A profile qualifies for every archetype whose conditions hold;
      // the one with the highest rank wins. rank.sum adds those axes,
      // rank.sumInverted adds (axisMax - axis).
      'rules': [
        {
          'archetype': 'boldExplorer',
          'when': [cond('body', '>=', 7), cond('complexity', '>=', 7)],
          'rank': {'sum': ['body', 'complexity']},
        },
        {
          'archetype': 'crispPurist',
          'when': [cond('acidity', '>=', 7), cond('freshness', '>=', 7)],
          'rank': {'sum': ['acidity', 'freshness']},
        },
        {
          'archetype': 'fruitForward',
          'when': [cond('fruit', '>=', 8)],
          'rank': {'sum': ['fruit']},
        },
        {
          'archetype': 'sweetTooth',
          'when': [cond('tannin', '<=', 3), cond('fruit', '>=', 7)],
          'rank': {'sum': ['fruit'], 'sumInverted': ['tannin']},
        },
        {
          'archetype': 'balancedSipper',
          'allAxes': {'min': 3, 'max': 7},
          'rank': {'lowVariance': 20},
        },
      ],
    };

    List<Map<String, Object?>> answers(List<QuizAnswer> list) => [
          for (final a in list)
            {
              'id': a.id,
              'label': a.label,
              'icon': icon(a.icon),
              'axes': {
                for (final e in a.axisContributions.entries) e.key.name: e.value,
              },
            },
        ];
    final quiz = {
      'axisMin': kAxisMin,
      'axisMax': kAxisMax,
      'quizBlendWeight': kQuizBlendWeight,
      'sliderBlendWeight': kSliderBlendWeight,
      'triedPriorWeight': kTriedPriorWeight,
      'steps': [
        {'id': 'foods', 'multi': true, 'answers': answers(kQuizStep1Foods)},
        {'id': 'chaat', 'multi': false, 'optional': true, 'answers': answers(kQuizStep2Chaat)},
        {'id': 'drinks', 'multi': false, 'answers': answers(kQuizStep3Drinks)},
      ],
    };

    const matcher = LabelMatcher();
    final scanner = {
      'minScore': matcher.minScore,
      'fuzzyThreshold': matcher.fuzzyThreshold,
      'minFuzzyWordLength': 4,
      'genericWords': LabelMatcher.genericWords.toList()..sort(),
    };

    final gamification = {
      'actions': {for (final a in GamificationAction.values) a.name: a.xp},
      'levels': [
        for (final e in kXpLevels.entries)
          {
            'level': e.key,
            'name': e.value.name,
            'minXp': e.value.minXp,
            'icon': icon(e.value.icon),
          },
      ],
    };

    Map<String, Object?> condition(BadgeCondition c) => switch (c) {
          ScanCountCondition(:final count) => {'type': 'scanCount', 'value': count},
          JournalCountCondition(:final count) => {'type': 'journalCount', 'value': count},
          PairingCountCondition(:final count) => {'type': 'pairingCount', 'value': count},
          StreakCondition(:final days) => {'type': 'streakDays', 'value': days},
          CategoryExploredCondition(:final category) => {'type': 'categoryExplored', 'value': category},
          ChallengeCountCondition(:final count) => {'type': 'challengeCount', 'value': count},
          SpecialCondition(:final key) => {'type': 'special', 'value': key},
          _ => throw StateError('unknown badge condition $c'),
        };
    final badges = {
      'items': [
        for (final b in kBadges)
          {
            'id': b.id,
            'name': b.name,
            'description': b.description,
            'icon': icon(b.icon),
            'xpReward': b.xpReward,
            'condition': condition(b.condition),
          },
      ],
    };

    final categories = {
      'palateAxes': [
        for (final a in PalateAxis.values) {'code': a.name, 'displayName': a.displayName},
      ],
      'drinkGroups': [
        {'name': 'Wine', 'image': 'assets/images/drinks/red_wine.jpg'},
        {'name': 'Whisky', 'image': 'assets/images/drinks/whisky.jpg'},
        {'name': 'Spirits', 'image': 'assets/images/drinks/cocktails.jpg'},
        {'name': 'Beer', 'image': 'assets/images/drinks/beer.jpg'},
      ],
      'drinks': [
        for (final c in DrinkCategory.values)
          {'code': c.name, 'displayName': c.displayName, 'group': c.group},
      ],
      'cuisines': [
        for (final c in FoodCategory.values)
          {'code': c.name, 'displayName': c.displayName, 'icon': icon(c.icon)},
      ],
      'foodProperties': [
        for (final p in FoodProperty.values) {'code': p.name, 'displayName': p.displayName},
      ],
      'pairingStrategies': [
        for (final s in PairingStrategy.values)
          {'code': s.name, 'displayName': s.displayName, 'description': s.description},
      ],
    };

    final occasions = {
      'items': [
        for (final o in Occasion.values)
          {
            'code': o.name,
            'displayName': o.displayName,
            'icon': icon(o.icon),
            'axisModifiers': {
              for (final e in o.axisModifiers.entries) e.key.name: e.value,
            },
            if (o.categoryBonus != null)
              'categoryBonus': {
                'category': o.categoryBonus!.category.name,
                'bonusPercent': o.categoryBonus!.bonusPercent,
              },
          },
      ],
    };

    final journalScales = {
      'noseIntensity': [for (final v in NoseIntensity.values) v.name],
      'sweetness': [for (final v in Sweetness.values) v.name],
      'acidity': [for (final v in AcidityLevel.values) v.name],
      'tannin': [for (final v in TanninLevel.values) v.name],
      'body': [for (final v in BodyLevel.values) v.name],
      'finish': [for (final v in FinishLength.values) v.name],
      'ratingMax': 5,
    };

    final aromaWheel = {
      'categories': [
        for (final c in kAromaWheel)
          {
            'name': c.name,
            'color': '#${c.color.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
            'subcategories': [
              for (final s in c.subcategories) {'name': s.name, 'aromas': s.aromas},
            ],
          },
      ],
      'desiTerms': kKnownDesiTerms.toList()..sort(),
      'calibration': {'count': 3, 'indianShare': 2 / 3},
    };

    final home = {
      'emotionTiles': [
        {'id': 'cooking', 'labelKey': 'homeEmotionCooking', 'icon': 'outdoor_grill', 'gradient': ['paprika', 'paprikaDeep'], 'route': '/pair'},
        {'id': 'hosting', 'labelKey': 'homeEmotionHosting', 'icon': 'celebration_outlined', 'gradient': ['thunder', 'paprikaDark'], 'route': '/pair'},
        {'id': 'justSipping', 'labelKey': 'homeEmotionJustSipping', 'icon': 'nightlight_round', 'gradient': ['paprikaDark', 'thunderLight'], 'route': '/pair'},
      ],
      'logo': 'assets/images/logo.png',
    };

    final notifications = {
      'types': [
        for (final t in WineBroNotificationType.values)
          {'code': t.code, 'deepLink': t.deepLink},
      ],
    };

    final config = {
      'pairingRules': pairingRules,
      'archetypes': archetypes,
      'quiz': quiz,
      'scanner': scanner,
      'gamification': gamification,
      'badges': badges,
      'categories': categories,
      'occasions': occasions,
      'journalScales': journalScales,
      'aromaWheel': aromaWheel,
      'home': home,
      'notifications': notifications,
    };
    final json = const JsonEncoder.withIndent('  ').convert(config);
    File('tool/config/config.json').writeAsStringSync(json);
    Directory('assets/config').createSync(recursive: true);
    File('assets/config/defaults.json').writeAsStringSync(json);
  });
}
