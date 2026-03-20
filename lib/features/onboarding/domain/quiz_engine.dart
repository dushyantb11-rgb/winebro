import 'package:flutter/material.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';

class QuizEngine {
  const QuizEngine();

  PalateProfile generateProfile({
    required List<QuizAnswer> foodAnswers,
    QuizAnswer? chaatAnswer,
    required QuizAnswer drinkAnswer,
    Map<PalateAxis, double>? sliderOverrides,
  }) {

    final rawScores = <PalateAxis, double>{
      for (final axis in PalateAxis.values) axis: 0.0,
    };

    for (final answer in foodAnswers) {
      for (final entry in answer.axisContributions.entries) {
        rawScores[entry.key] = rawScores[entry.key]! + entry.value;
      }
    }

    if (chaatAnswer != null) {
      for (final entry in chaatAnswer.axisContributions.entries) {
        rawScores[entry.key] = rawScores[entry.key]! + entry.value;
      }
    }

    for (final entry in drinkAnswer.axisContributions.entries) {
      rawScores[entry.key] = rawScores[entry.key]! + entry.value;
    }

    final normalizedQuiz = _normalize(rawScores);

    final blended = <PalateAxis, double>{};
    for (final axis in PalateAxis.values) {
      final quizScore = normalizedQuiz[axis]!;
      final sliderScore = sliderOverrides?[axis] ?? quizScore;
      blended[axis] =
          (kQuizBlendWeight * quizScore + kSliderBlendWeight * sliderScore)
              .clamp(kAxisMin, kAxisMax);
    }

    final archetype = classifyArchetype(blended);

    return PalateProfile(
      fruit: blended[PalateAxis.fruit]!,
      acidity: blended[PalateAxis.acidity]!,
      body: blended[PalateAxis.body]!,
      tannin: blended[PalateAxis.tannin]!,
      freshness: blended[PalateAxis.freshness]!,
      complexity: blended[PalateAxis.complexity]!,
      archetype: archetype,
    );
  }

  Map<PalateAxis, double> _normalize(Map<PalateAxis, double> raw) {

    final values = raw.values.toList();
    var minVal = values.reduce((a, b) => a < b ? a : b);
    var maxVal = values.reduce((a, b) => a > b ? a : b);

    if (maxVal == minVal) {
      minVal = 0;
      maxVal = maxVal == 0 ? 1 : maxVal;
    }

    final range = maxVal - minVal;
    return {
      for (final axis in PalateAxis.values)
        axis: ((raw[axis]! - minVal) / range * kAxisMax).clamp(
          kAxisMin,
          kAxisMax,
        ),
    };
  }

  PalateArchetype classifyArchetype(Map<PalateAxis, double> scores) {
    final body = scores[PalateAxis.body]!;
    final complexity = scores[PalateAxis.complexity]!;
    final acidity = scores[PalateAxis.acidity]!;
    final freshness = scores[PalateAxis.freshness]!;
    final fruit = scores[PalateAxis.fruit]!;
    final tannin = scores[PalateAxis.tannin]!;

    final candidates = <(PalateArchetype, double)>[];

    if (body >= 7 && complexity >= 7) {
      candidates.add((PalateArchetype.boldExplorer, body + complexity));
    }

    if (acidity >= 7 && freshness >= 7) {
      candidates.add((PalateArchetype.crispPurist, acidity + freshness));
    }

    if (fruit >= 8) {
      candidates.add((PalateArchetype.fruitForward, fruit));
    }

    if (tannin <= 3 && fruit >= 7) {
      candidates.add((PalateArchetype.sweetTooth, fruit + (10 - tannin)));
    }

    final allBalanced = scores.values.every((v) => v >= 3 && v <= 7);
    if (allBalanced) {

      final mean = scores.values.reduce((a, b) => a + b) / scores.length;
      final variance = scores.values
              .map((v) => (v - mean) * (v - mean))
              .reduce((a, b) => a + b) /
          scores.length;
      candidates.add((PalateArchetype.balancedSipper, 20 - variance));
    }

    if (candidates.isEmpty) {
      return PalateArchetype.balancedSipper;
    }

    candidates.sort((a, b) => b.$2.compareTo(a.$2));
    return candidates.first.$1;
  }
}

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
}

const kQuizStep1Foods = <QuizAnswer>[
  QuizAnswer(
    id: 'butter-chicken',
    label: 'Butter Chicken',
    icon: Icons.restaurant,
    axisContributions: {
      PalateAxis.fruit: 3,
      PalateAxis.acidity: 2,
      PalateAxis.body: 5,
      PalateAxis.tannin: 2,
      PalateAxis.freshness: 1,
      PalateAxis.complexity: 3,
    },
  ),
  QuizAnswer(
    id: 'biryani',
    label: 'Biryani',
    icon: Icons.rice_bowl,
    axisContributions: {
      PalateAxis.fruit: 2,
      PalateAxis.acidity: 2,
      PalateAxis.body: 4,
      PalateAxis.tannin: 2,
      PalateAxis.freshness: 1,
      PalateAxis.complexity: 5,
    },
  ),
  QuizAnswer(
    id: 'pani-puri',
    label: 'Pani Puri / Chaat',
    icon: Icons.lunch_dining,
    axisContributions: {
      PalateAxis.fruit: 3,
      PalateAxis.acidity: 5,
      PalateAxis.body: 1,
      PalateAxis.tannin: 1,
      PalateAxis.freshness: 4,
      PalateAxis.complexity: 3,
    },
  ),
  QuizAnswer(
    id: 'masala-dosa',
    label: 'Masala Dosa',
    icon: Icons.breakfast_dining,
    axisContributions: {
      PalateAxis.fruit: 1,
      PalateAxis.acidity: 3,
      PalateAxis.body: 1,
      PalateAxis.tannin: 1,
      PalateAxis.freshness: 3,
      PalateAxis.complexity: 2,
    },
  ),
  QuizAnswer(
    id: 'paneer-tikka',
    label: 'Paneer Tikka',
    icon: Icons.kebab_dining,
    axisContributions: {
      PalateAxis.fruit: 2,
      PalateAxis.acidity: 3,
      PalateAxis.body: 3,
      PalateAxis.tannin: 2,
      PalateAxis.freshness: 1,
      PalateAxis.complexity: 3,
    },
  ),
  QuizAnswer(
    id: 'vada-pav',
    label: 'Vada Pav',
    icon: Icons.fastfood,
    axisContributions: {
      PalateAxis.fruit: 2,
      PalateAxis.acidity: 2,
      PalateAxis.body: 4,
      PalateAxis.tannin: 2,
      PalateAxis.freshness: 1,
      PalateAxis.complexity: 2,
    },
  ),
  QuizAnswer(
    id: 'dal-makhani',
    label: 'Dal Makhani',
    icon: Icons.soup_kitchen,
    axisContributions: {
      PalateAxis.fruit: 3,
      PalateAxis.acidity: 1,
      PalateAxis.body: 5,
      PalateAxis.tannin: 1,
      PalateAxis.freshness: 1,
      PalateAxis.complexity: 3,
    },
  ),
  QuizAnswer(
    id: 'goan-fish-curry',
    label: 'Goan Fish Curry',
    icon: Icons.set_meal,
    axisContributions: {
      PalateAxis.fruit: 2,
      PalateAxis.acidity: 4,
      PalateAxis.body: 3,
      PalateAxis.tannin: 1,
      PalateAxis.freshness: 3,
      PalateAxis.complexity: 3,
    },
  ),
];

const kQuizStep2Chaat = <QuizAnswer>[
  QuizAnswer(
    id: 'pani-puri-tangy',
    label: 'Pani Puri — the tangy water burst!',
    icon: Icons.water_drop,
    axisContributions: {
      PalateAxis.acidity: 3,
      PalateAxis.freshness: 2,
    },
  ),
  QuizAnswer(
    id: 'sev-puri',
    label: 'Sev Puri — perfect balance of chutneys',
    icon: Icons.dining,
    axisContributions: {
      PalateAxis.complexity: 2,
      PalateAxis.fruit: 1,
      PalateAxis.acidity: 1,
    },
  ),
  QuizAnswer(
    id: 'bhel-puri',
    label: 'Bhel Puri — light and crunchy',
    icon: Icons.grain,
    axisContributions: {
      PalateAxis.freshness: 3,
      PalateAxis.body: -1,
    },
  ),
  QuizAnswer(
    id: 'dahi-puri',
    label: 'Dahi Puri — cool and creamy',
    icon: Icons.local_cafe,
    axisContributions: {
      PalateAxis.fruit: 2,
      PalateAxis.body: 1,
      PalateAxis.freshness: 1,
    },
  ),
  QuizAnswer(
    id: 'ragda-pattice',
    label: 'Ragda Pattice — hearty and filling',
    icon: Icons.brunch_dining,
    axisContributions: {
      PalateAxis.body: 3,
      PalateAxis.complexity: 1,
    },
  ),
  QuizAnswer(
    id: 'papdi-chaat',
    label: 'Papdi Chaat — classic all-rounder',
    icon: Icons.star,
    axisContributions: {
      PalateAxis.acidity: 1,
      PalateAxis.fruit: 1,
      PalateAxis.freshness: 1,
      PalateAxis.complexity: 1,
    },
  ),
];

const kQuizStep3Drinks = <QuizAnswer>[
  QuizAnswer(
    id: 'old-monk-cola',
    label: 'Old Monk & Cola',
    icon: Icons.local_bar,
    axisContributions: {
      PalateAxis.fruit: 3,
      PalateAxis.body: 3,
      PalateAxis.complexity: 2,
    },
  ),
  QuizAnswer(
    id: 'aam-panna',
    label: 'Aam Panna',
    icon: Icons.local_drink,
    axisContributions: {
      PalateAxis.acidity: 3,
      PalateAxis.fruit: 3,
      PalateAxis.freshness: 2,
    },
  ),
  QuizAnswer(
    id: 'masala-chai',
    label: 'Masala Chai',
    icon: Icons.coffee,
    axisContributions: {
      PalateAxis.body: 2,
      PalateAxis.complexity: 3,
      PalateAxis.tannin: 2,
    },
  ),
  QuizAnswer(
    id: 'jaljeera',
    label: 'Jaljeera',
    icon: Icons.spa,
    axisContributions: {
      PalateAxis.acidity: 3,
      PalateAxis.freshness: 3,
      PalateAxis.complexity: 1,
    },
  ),
  QuizAnswer(
    id: 'mango-lassi',
    label: 'Mango Lassi',
    icon: Icons.local_drink,
    axisContributions: {
      PalateAxis.fruit: 4,
      PalateAxis.body: 2,
      PalateAxis.freshness: 1,
    },
  ),
  QuizAnswer(
    id: 'sol-kadhi',
    label: 'Sol Kadhi / Kokum',
    icon: Icons.local_drink,
    axisContributions: {
      PalateAxis.acidity: 3,
      PalateAxis.freshness: 2,
      PalateAxis.fruit: 2,
    },
  ),
  QuizAnswer(
    id: 'gin-tonic',
    label: 'Gin & Tonic',
    icon: Icons.liquor,
    axisContributions: {
      PalateAxis.freshness: 3,
      PalateAxis.acidity: 2,
      PalateAxis.complexity: 2,
    },
  ),
  QuizAnswer(
    id: 'thandai',
    label: 'Thandai',
    icon: Icons.local_cafe,
    axisContributions: {
      PalateAxis.complexity: 3,
      PalateAxis.body: 2,
      PalateAxis.fruit: 2,
    },
  ),
  QuizAnswer(
    id: 'surprise-me',
    label: 'Other / Surprise me',
    icon: Icons.casino,
    axisContributions: {
      PalateAxis.fruit: 2,
      PalateAxis.acidity: 2,
      PalateAxis.body: 2,
      PalateAxis.tannin: 2,
      PalateAxis.freshness: 2,
      PalateAxis.complexity: 2,
    },
  ),
];

