import 'dart:math' as math;

import 'package:winebro/core/config/app_config.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/pairing_feedback/domain/pairing_aggregate.dart';

/// Maximum +/- score nudge from community feedback (engine v1.1).
double get kFeedbackBiasCapPoints =>
    AppConfig.current.pairingRules.feedbackBiasCapPoints;

/// Share of the food fit in "what to drink with this dish"; the rest is
/// the user's palate match.
double get kFoodWeight => AppConfig.current.pairingRules.foodWeight;

/// Extra points for a hand-written pairing of this dish and drink.
double get kCuratedBonus => AppConfig.current.pairingRules.curatedBonus;

/// Scores drinks for a palate, a dish or an occasion using the rules in
/// `config/pairingRules`. Pass [rules] to score with a specific rule set
/// (tests, admin preview); otherwise the live config is used.
class PairingEngine {
  const PairingEngine({this.rules});

  final PairingRulesConfig? rules;

  PairingRulesConfig get _r => rules ?? AppConfig.current.pairingRules;

  PairingResult computeMatch({
    required PalateProfile userProfile,
    required Product product,
    Occasion? occasion,
    int recommendationCount = 0,
    bool userRated5Stars = false,
  }) {
    final r = _r;
    final effectiveProfile =
        occasion != null ? userProfile.withOccasion(occasion) : userProfile;

    final baseScore = _weightedCosineSimilarity(effectiveProfile, product, r);
    final archetypeBonus = _archetypeBonus(userProfile.archetype, product);
    final occasionBonus = _occasionCategoryBonus(occasion, product);
    final frequencyPenalty =
        _frequencyPenalty(recommendationCount, userRated5Stars, r);

    final rawScore =
        baseScore + archetypeBonus + occasionBonus + frequencyPenalty;
    final finalScore = rawScore.clamp(r.scoreFloor, r.scoreCeiling);

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
    final results = [
      for (final product in products)
        computeMatch(
          userProfile: userProfile,
          product: product,
          occasion: occasion,
          recommendationCount: 0,
        ),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return results.take(topN).toList();
  }

  List<FoodPairingResult> suggestFoodForDrink({
    required Product product,
    required List<Dish> dishes,
    int topN = 5,
  }) {
    final r = _r;
    final results = <FoodPairingResult>[];

    for (final dish in dishes) {
      final score = _foodFit(dish, product, r);
      final strategy = _determinePairingStrategy(dish.foodProperties, product, r);
      final curated = _curatedPairing(dish, product);

      results.add(FoodPairingResult(
        dish: dish,
        product: product,
        score: score,
        strategy: curated?.strategy ?? strategy,
        explanation: curated?.broTip ??
            _generatePairingExplanation(dish, product, strategy, r),
        isCurated: curated != null,
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
    final r = _r;
    final results = <PairingResult>[];

    for (final product in products) {
      final userMatch = computeMatch(
        userProfile: userProfile,
        product: product,
        occasion: occasion,
      );
      final foodScore = _foodFit(dish, product, r);
      final feedbackBonus = _feedbackBonus(product.id, feedbackAggregates, r);

      // For "what to drink with this dish" the dish matters most.
      final blendedScore = (foodScore * r.foodWeight +
              userMatch.score * (1 - r.foodWeight) +
              feedbackBonus)
          .clamp(r.scoreFloor, r.scoreCeiling);

      results.add(PairingResult(
        product: product,
        score: blendedScore,
        baseScore: userMatch.baseScore,
        archetypeBonus: userMatch.archetypeBonus,
        occasionBonus: userMatch.occasionBonus,
        frequencyPenalty: 0,
        feedbackBonus: feedbackBonus,
        broTip: _curatedPairing(dish, product)?.broTip,
      ));
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(topN).toList();
  }

  /// Score breakdown of one dish and drink, for the admin "try a
  /// pairing" preview and tests.
  FoodFitBreakdown explainFoodFit(Dish dish, Product product) {
    final r = _r;
    final lines = <({FoodProperty property, double points})>[];
    for (final prop in dish.foodProperties) {
      lines.add((property: prop, points: _rulePoints(prop, product, r) ?? 0));
    }
    final curated = _curatedPairing(dish, product);
    return FoodFitBreakdown(
      base: r.foodFitBase,
      rulePoints: lines,
      curatedScore: curated?.score,
      curatedBonus: curated == null ? 0 : r.curatedBonus,
      total: _foodFit(dish, product, r),
      strategy: curated?.strategy ??
          _determinePairingStrategy(dish.foodProperties, product, r),
    );
  }

  /// Engine v1.1: convert a community pairing aggregate (yes/maybe/no
  /// counters) into a points-bonus added to the match score.
  double _feedbackBonus(
    String productId,
    Map<String, PairingAggregate>? aggregates,
    PairingRulesConfig r,
  ) {
    final agg = aggregates?[productId];
    if (agg == null) return 0;
    return agg.signedShrunkBias() * 2 * r.feedbackBiasCapPoints;
  }

  /// Hand-written pairing for this dish and drink, if one exists in the
  /// dish catalogue.
  DishPairing? _curatedPairing(Dish dish, Product product) =>
      dish.pairings.where((p) => p.productId == product.id).firstOrNull;

  double _weightedCosineSimilarity(
    PalateProfile user,
    Product product,
    PairingRulesConfig r,
  ) {
    var dotProduct = 0.0;
    var userMagnitude = 0.0;
    var productMagnitude = 0.0;

    for (final axis in PalateAxis.values) {
      final w = r.axisWeights[axis] ?? 1.0;
      final u = user[axis];
      final p = product[axis];

      dotProduct += w * u * p;
      userMagnitude += w * u * u;
      productMagnitude += w * p * p;
    }

    final denominator = math.sqrt(userMagnitude) * math.sqrt(productMagnitude);
    if (denominator == 0) return r.scoreFloor;
    return (dotProduct / denominator) * 100;
  }

  double _archetypeBonus(PalateArchetype userArchetype, Product product) {
    if (product.archetypeTags.contains(userArchetype)) {
      return userArchetype.bonusPercent.toDouble();
    }
    return 0;
  }

  double _occasionCategoryBonus(Occasion? occasion, Product product) {
    final bonus = occasion?.categoryBonus;
    if (bonus != null && product.category == bonus.category) {
      return bonus.bonusPercent;
    }
    return 0;
  }

  double _frequencyPenalty(
    int count,
    bool userRated5Stars,
    PairingRulesConfig r,
  ) {
    if (userRated5Stars) return 0;
    return switch (count) {
      0 => 0,
      1 => r.frequencyPenaltySecond,
      2 => r.frequencyPenaltyThird,
      _ => r.frequencyPenaltyCap,
    };
  }

  /// Food fit on the match scale: the base plus the points of every
  /// matching rule (minus clashes). A hand-written pairing for this dish
  /// and drink sets a floor at its own score, plus the curated bonus.
  double _foodFit(Dish dish, Product product, PairingRulesConfig r) {
    var points = r.foodFitBase;
    for (final prop in dish.foodProperties) {
      points += _rulePoints(prop, product, r) ?? 0;
    }
    final curated = _curatedPairing(dish, product);
    if (curated != null) {
      points = math.max(points, curated.score.toDouble()) + r.curatedBonus;
    }
    return points.clamp(r.scoreFloor, r.scoreCeiling);
  }

  /// Points of the first rule for [prop] whose conditions the drink
  /// meets; null when none applies.
  double? _rulePoints(FoodProperty prop, Product product, PairingRulesConfig r) {
    for (final rule in r.foodFitRules[prop.name] ?? const <PointsRule>[]) {
      if (allHold(rule.when, (a) => product[a])) return rule.points;
    }
    return null;
  }

  PairingStrategy _determinePairingStrategy(
    List<FoodProperty> foodProps,
    Product product,
    PairingRulesConfig r,
  ) {
    int count(List<StrategyIndicator> indicators) => indicators
        .where((i) =>
            foodProps.contains(i.property) &&
            allHold(i.when, (a) => product[a]))
        .length;

    return count(r.contrastIndicators) > count(r.complementIndicators)
        ? PairingStrategy.contrast
        : PairingStrategy.complement;
  }

  String _generatePairingExplanation(
    Dish dish,
    Product product,
    PairingStrategy strategy,
    PairingRulesConfig r,
  ) {
    String fill(String text, {String why = ''}) => text
        .replaceAll('{dish}', dish.name)
        .replaceAll('{drink}', product.name)
        .replaceAll('{strategy}', strategy.displayName.toLowerCase())
        .replaceAll('{why}', why);

    for (final t in r.explanations) {
      if (t.strategy != strategy || !dish.foodProperties.contains(t.property)) {
        continue;
      }
      var why = '';
      for (final v in t.why) {
        if (allHold(v.when, (a) => product[a])) {
          why = v.text;
          break;
        }
      }
      return fill(t.text, why: why);
    }
    return fill(r.explanationDefault);
  }
}

class FoodFitBreakdown {
  const FoodFitBreakdown({
    required this.base,
    required this.rulePoints,
    required this.curatedScore,
    required this.curatedBonus,
    required this.total,
    required this.strategy,
  });

  final double base;
  final List<({FoodProperty property, double points})> rulePoints;
  final double? curatedScore;
  final double curatedBonus;
  final double total;
  final PairingStrategy strategy;
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
    this.broTip,
  });

  final Product product;
  final double score;
  final double baseScore;
  final double archetypeBonus;
  final double occasionBonus;
  final double frequencyPenalty;

  /// Community feedback nudge (engine v1.1), 0 when no data.
  final double feedbackBonus;

  /// Hand-written tip for this dish and drink, when one exists.
  final String? broTip;

  int get matchPercent => score.round();
}

class FoodPairingResult {
  const FoodPairingResult({
    required this.dish,
    required this.product,
    required this.score,
    required this.strategy,
    required this.explanation,
    this.isCurated = false,
  });

  final Dish dish;
  final Product product;
  final double score;
  final PairingStrategy strategy;
  final String explanation;

  /// True when the tip and strategy come from the dish catalogue.
  final bool isCurated;

  int get matchPercent => score.round();
}
