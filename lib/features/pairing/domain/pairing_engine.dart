import 'dart:math' as math;

import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/pairing_feedback/domain/pairing_aggregate.dart';

/// Maximum +/- score nudge from community feedback (engine v1.1).
/// At full confidence (large sample, all Yes), bias is +0.5 multiplied
/// by this cap → adds at most this many points to the match score.
const double kFeedbackBiasCapPoints = 10;

class PairingEngine {
  const PairingEngine();

  PairingResult computeMatch({
    required PalateProfile userProfile,
    required Product product,
    Occasion? occasion,
    int recommendationCount = 0,
    bool userRated5Stars = false,
  }) {

    final effectiveProfile = occasion != null
        ? userProfile.withOccasion(occasion)
        : userProfile;

    final baseScore = _weightedCosineSimilarity(
      effectiveProfile,
      product,
    );

    final archetypeBonus = _archetypeBonus(userProfile.archetype, product);

    final occasionBonus = _occasionCategoryBonus(occasion, product);

    final frequencyPenalty = _frequencyPenalty(
      recommendationCount,
      userRated5Stars,
    );

    final rawScore =
        baseScore + archetypeBonus + occasionBonus + frequencyPenalty;
    final finalScore = rawScore.clamp(kScoreFloor, kScoreCeiling);

    return PairingResult(
      product: product,
      score: finalScore,
      baseScore: baseScore,
      archetypeBonus: archetypeBonus,
      occasionBonus: occasionBonus,
      frequencyPenalty: frequencyPenalty,
    );
  }

  List<PairingResult> rankProducts({
    required PalateProfile userProfile,
    required List<Product> products,
    Occasion? occasion,
    int topN = 10,
  }) {
    final results = <PairingResult>[];

    for (var i = 0; i < products.length; i++) {
      results.add(computeMatch(
        userProfile: userProfile,
        product: products[i],
        occasion: occasion,
        recommendationCount: 0,
      ));
    }

    results.sort((a, b) => b.score.compareTo(a.score));

    return results.take(topN).toList();
  }

  List<FoodPairingResult> suggestFoodForDrink({
    required Product product,
    required List<Dish> dishes,
    int topN = 5,
  }) {
    final results = <FoodPairingResult>[];

    for (final dish in dishes) {
      final ruleScore = _foodDrinkRuleScore(dish.foodProperties, product);
      final score = (ruleScore * 100).clamp(kScoreFloor, kScoreCeiling);

      final strategy = _determinePairingStrategy(dish.foodProperties, product);

      results.add(FoodPairingResult(
        dish: dish,
        product: product,
        score: score,
        strategy: strategy,
        explanation: _generatePairingExplanation(
          dish,
          product,
          strategy,
        ),
      ));
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(topN).toList();
  }

  List<PairingResult> suggestDrinkForFood({
    required PalateProfile userProfile,
    required Dish dish,
    required List<Product> products,
    Occasion? occasion,
    int topN = 5,
    Map<String, PairingAggregate>? feedbackAggregates,
  }) {
    final results = <PairingResult>[];

    for (final product in products) {

      final userMatch = computeMatch(
        userProfile: userProfile,
        product: product,
        occasion: occasion,
      );

      final foodScore = _foodDrinkRuleScore(dish.foodProperties, product);

      final feedbackBonus =
          _feedbackBonus(product.id, feedbackAggregates);

      final blendedScore =
          (userMatch.score * 0.6 + foodScore * 100 * 0.4 + feedbackBonus)
              .clamp(kScoreFloor, kScoreCeiling);

      results.add(PairingResult(
        product: product,
        score: blendedScore,
        baseScore: userMatch.baseScore,
        archetypeBonus: userMatch.archetypeBonus,
        occasionBonus: userMatch.occasionBonus,
        frequencyPenalty: 0,
        feedbackBonus: feedbackBonus,
      ));
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(topN).toList();
  }

  /// Engine v1.1: convert a community pairing aggregate (yes/maybe/no
  /// counters) into a points-bonus added to the match score.
  ///
  /// Bias = signedShrunkBias ∈ [-0.5, 0.5] · 2 · cap → points ∈ [-cap, cap].
  /// Multiplying by 2 brings the [-0.5, 0.5] range to [-1, 1] before
  /// scaling — i.e., a fully one-sided community would shift +/- the
  /// full cap; in practice the Bayesian shrinkage holds early picks
  /// near zero until enough samples land.
  double _feedbackBonus(
    String productId,
    Map<String, PairingAggregate>? aggregates,
  ) {
    if (aggregates == null) return 0;
    final agg = aggregates[productId];
    if (agg == null) return 0;
    return agg.signedShrunkBias() * 2 * kFeedbackBiasCapPoints;
  }

  double _weightedCosineSimilarity(PalateProfile user, Product product) {
    var dotProduct = 0.0;
    var userMagnitude = 0.0;
    var productMagnitude = 0.0;

    for (final axis in PalateAxis.values) {
      final w = axis.defaultWeight;
      final u = user[axis];
      final p = product[axis];

      dotProduct += w * u * p;
      userMagnitude += w * u * u;
      productMagnitude += w * p * p;
    }

    final denominator =
        math.sqrt(userMagnitude) * math.sqrt(productMagnitude);

    if (denominator == 0) return kScoreFloor;

    return (dotProduct / denominator) * 100;
  }

  double _archetypeBonus(PalateArchetype userArchetype, Product product) {
    if (product.archetypeTags.contains(userArchetype)) {
      return userArchetype.bonusPercent.toDouble();
    }
    return 0;
  }

  double _occasionCategoryBonus(Occasion? occasion, Product product) {
    if (occasion == null) return 0;
    final bonus = occasion.categoryBonus;
    if (bonus != null && product.category == bonus.category) {
      return bonus.bonusPercent;
    }
    return 0;
  }

  double _frequencyPenalty(int count, bool userRated5Stars) {
    if (userRated5Stars) return 0;
    return switch (count) {
      0 => 0,
      1 => kFrequencyPenalty2nd,
      2 => kFrequencyPenalty3rd,
      _ => kFrequencyPenaltyCap,
    };
  }

  double _foodDrinkRuleScore(List<FoodProperty> foodProps, Product product) {
    var score = 0.5;
    var ruleCount = 0;

    for (final prop in foodProps) {
      final ruleResult = _applyInteractionRule(prop, product);
      if (ruleResult != null) {
        score += ruleResult;
        ruleCount++;
      }
    }

    if (ruleCount > 0) {
      score = score / (1 + ruleCount * 0.3);
      score += ruleCount * 0.08;
    }

    return score.clamp(0.4, 0.99);
  }

  double? _applyInteractionRule(FoodProperty foodProp, Product product) {
    return switch (foodProp) {

      FoodProperty.highFat =>
        product.acidity >= 6 ? 0.15 : (product.acidity <= 3 ? -0.1 : null),

      FoodProperty.spicyHeat =>
        product.fruit >= 6 && product.tannin <= 4
            ? 0.2
            : (product.tannin >= 7 ? -0.15 : null),

      FoodProperty.highProtein =>
        product.tannin >= 6 ? 0.15 : null,

      FoodProperty.lightDelicate =>
        product.body <= 4 ? 0.15 : (product.body >= 7 ? -0.15 : null),

      FoodProperty.sweetDessert =>
        product.fruit >= 7 ? 0.15 : (product.tannin >= 6 ? -0.2 : null),

      FoodProperty.umamiRich =>
        product.fruit >= 6 && product.tannin <= 4 ? 0.15 : null,

      FoodProperty.acidic =>
        product.acidity >= 6 ? 0.12 : (product.acidity <= 3 ? -0.1 : null),

      FoodProperty.smokyCharred =>
        product.complexity >= 6 && product.body >= 5 ? 0.15 : null,

      FoodProperty.creamy =>
        product.acidity >= 5 ? 0.1 : null,

      FoodProperty.tangy =>
        product.acidity >= 5 && product.freshness >= 5 ? 0.12 : null,

      FoodProperty.aromatic =>
        product.complexity >= 5 ? 0.1 : null,
    };
  }

  PairingStrategy _determinePairingStrategy(
    List<FoodProperty> foodProps,
    Product product,
  ) {

    final contrastIndicators = [
      foodProps.contains(FoodProperty.highFat) && product.acidity >= 6,
      foodProps.contains(FoodProperty.spicyHeat) && product.fruit >= 6,
      foodProps.contains(FoodProperty.umamiRich) && product.fruit >= 6,
    ];

    final complementIndicators = [
      foodProps.contains(FoodProperty.highProtein) && product.tannin >= 6,
      foodProps.contains(FoodProperty.lightDelicate) && product.body <= 4,
      foodProps.contains(FoodProperty.sweetDessert) && product.fruit >= 7,
      foodProps.contains(FoodProperty.smokyCharred) && product.complexity >= 6,
      foodProps.contains(FoodProperty.acidic) && product.acidity >= 6,
    ];

    final contrastScore = contrastIndicators.where((b) => b).length;
    final complementScore = complementIndicators.where((b) => b).length;

    return contrastScore > complementScore
        ? PairingStrategy.contrast
        : PairingStrategy.complement;
  }

  String _generatePairingExplanation(
    Dish dish,
    Product product,
    PairingStrategy strategy,
  ) {
    final foodProps = dish.foodProperties;

    if (strategy == PairingStrategy.contrast) {
      if (foodProps.contains(FoodProperty.spicyHeat)) {
        return 'The ${dish.name} brings serious heat, Bro. '
            '${product.name}\'s fruity sweetness tames the spice '
            'without killing the flavour. Classic contrast pairing.';
      }
      if (foodProps.contains(FoodProperty.highFat)) {
        return 'Rich, creamy ${dish.name} needs a palate cleanser. '
            '${product.name}\'s bright acidity cuts through the '
            'richness like a charm. Your mouth stays fresh.';
      }
      if (foodProps.contains(FoodProperty.umamiRich)) {
        return '${dish.name} is packed with umami depth. '
            '${product.name}\'s fruit-forward character provides '
            'the contrast your palate craves. Beautiful balance.';
      }
    }

    if (strategy == PairingStrategy.complement) {
      if (foodProps.contains(FoodProperty.smokyCharred)) {
        return 'Smoke meets smoke, Bro. ${dish.name}\'s charred notes '
            'find a soulmate in ${product.name}\'s complex, '
            'oak-aged character. They amplify each other.';
      }
      if (foodProps.contains(FoodProperty.highProtein)) {
        return '${dish.name}\'s protein is the perfect dance partner '
            'for ${product.name}\'s tannins. The tannin binds to '
            'protein and softens — making the wine taste smoother.';
      }
      if (foodProps.contains(FoodProperty.lightDelicate)) {
        return 'Delicate ${dish.name} needs a gentle companion. '
            '${product.name}\'s light body won\'t overpower the '
            'subtle flavours. Weight-matching at its finest.';
      }
    }

    return '${product.name} and ${dish.name} are a solid match. '
        'The ${strategy.displayName.toLowerCase()} pairing brings '
        'out the best in both — trust your Bro on this one.';
  }
}

class PairingResult {
  const PairingResult({
    required this.product,
    required this.score,
    required this.baseScore,
    required this.archetypeBonus,
    required this.occasionBonus,
    required this.frequencyPenalty,
    this.feedbackBonus = 0,
  });

  final Product product;
  final double score;
  final double baseScore;
  final double archetypeBonus;
  final double occasionBonus;
  final double frequencyPenalty;

  /// Points added to the score from engine v1.1's community
  /// feedback aggregate (Bayesian-shrunk yes-rate). Zero when no
  /// community signal exists for this (product, dish) pair.
  final double feedbackBonus;

  int get matchPercent => score.round();
}

class FoodPairingResult {
  const FoodPairingResult({
    required this.dish,
    required this.product,
    required this.score,
    required this.strategy,
    required this.explanation,
  });

  final Dish dish;
  final Product product;
  final double score;
  final PairingStrategy strategy;
  final String explanation;

  int get matchPercent => score.round();
}

