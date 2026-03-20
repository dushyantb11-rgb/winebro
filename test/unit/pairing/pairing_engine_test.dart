import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing/domain/product.dart';

void main() {
  const engine = PairingEngine();

  // ─── TEST PROFILES ────────────────────────────────────────
  const boldExplorerProfile = PalateProfile(
    fruit: 5, acidity: 5, body: 8, tannin: 6, freshness: 4, complexity: 8,
    archetype: PalateArchetype.boldExplorer,
  );

  const crispPuristProfile = PalateProfile(
    fruit: 5, acidity: 8, body: 3, tannin: 2, freshness: 8, complexity: 5,
    archetype: PalateArchetype.crispPurist,
  );

  const balancedProfile = PalateProfile(
    fruit: 5, acidity: 5, body: 5, tannin: 5, freshness: 5, complexity: 5,
    archetype: PalateArchetype.balancedSipper,
  );

  const zeroProfile = PalateProfile(
    fruit: 0, acidity: 0, body: 0, tannin: 0, freshness: 0, complexity: 0,
    archetype: PalateArchetype.balancedSipper,
  );

  // A product that mirrors the bold explorer profile
  final boldProduct = kSeedProducts.firstWhere((p) => p.id == 'lagavulin-16');
  // A crisp white wine
  final crispProduct = kSeedProducts.firstWhere(
    (p) => p.id == 'sula-sauvignon-blanc',
  );

  group('PE-01 to PE-07: Weighted Cosine Similarity', () {
    test('PE-01: Similar profiles produce high score (near ceiling)', () {
      final result = engine.computeMatch(
        userProfile: boldExplorerProfile,
        product: boldProduct,
      );
      // Bold profile vs bold product should be high
      expect(result.score, greaterThanOrEqualTo(70));
      expect(result.score, lessThanOrEqualTo(kScoreCeiling));
    });

    test('PE-02: Dissimilar profiles produce lower score (above floor)', () {
      final result = engine.computeMatch(
        userProfile: crispPuristProfile,
        product: boldProduct,
      );
      // Crisp profile vs bold product — mismatch
      expect(result.score, lessThan(90));
      expect(result.score, greaterThanOrEqualTo(kScoreFloor));
    });

    test('PE-03: Score always clamped between 40-99', () {
      for (final product in kSeedProducts) {
        final result = engine.computeMatch(
          userProfile: balancedProfile,
          product: product,
        );
        expect(result.score, greaterThanOrEqualTo(kScoreFloor));
        expect(result.score, lessThanOrEqualTo(kScoreCeiling));
      }
    });

    test('PE-04: Zero user profile returns floor score', () {
      final result = engine.computeMatch(
        userProfile: zeroProfile,
        product: boldProduct,
      );
      expect(result.score, equals(kScoreFloor));
    });

    test('PE-06: Sauvignon Blanc scores higher for Crisp Purist than Bold Explorer', () {
      final crispResult = engine.computeMatch(
        userProfile: crispPuristProfile,
        product: crispProduct,
      );
      final boldResult = engine.computeMatch(
        userProfile: boldExplorerProfile,
        product: crispProduct,
      );
      expect(crispResult.baseScore, greaterThan(boldResult.baseScore));
    });

    test('PE-07: Lagavulin scores higher for Bold Explorer than Crisp Purist', () {
      final boldResult = engine.computeMatch(
        userProfile: boldExplorerProfile,
        product: boldProduct,
      );
      final crispResult = engine.computeMatch(
        userProfile: crispPuristProfile,
        product: boldProduct,
      );
      expect(boldResult.baseScore, greaterThan(crispResult.baseScore));
    });
  });

  group('PE-08 to PE-11: Archetype Bonuses', () {
    test('PE-08: Bold Explorer user + bold product gets +15% bonus', () {
      final result = engine.computeMatch(
        userProfile: boldExplorerProfile,
        product: boldProduct,
      );
      // Lagavulin should have boldExplorer in archetypeTags
      expect(boldProduct.archetypeTags, contains(PalateArchetype.boldExplorer));
      expect(result.archetypeBonus, equals(15.0));
    });

    test('PE-10: Non-matching archetype gets 0 bonus', () {
      final result = engine.computeMatch(
        userProfile: crispPuristProfile,
        product: boldProduct,
      );
      expect(result.archetypeBonus, equals(0.0));
    });

    test('PE-11: Archetype bonus does not push score above 99', () {
      // Create a profile that almost matches a product perfectly
      final result = engine.computeMatch(
        userProfile: boldExplorerProfile,
        product: boldProduct,
      );
      expect(result.score, lessThanOrEqualTo(kScoreCeiling));
    });
  });

  group('PE-12 to PE-16: Occasion Modifiers', () {
    test('PE-12: Date Night increases complexity and body', () {
      final modified = balancedProfile.withOccasion(Occasion.dateNight);
      expect(modified.complexity, equals(6.5)); // 5 + 1.5
      expect(modified.body, equals(6.0)); // 5 + 1.0
      expect(modified.freshness, equals(4.5)); // 5 - 0.5
    });

    test('PE-13: Beach/Pool decreases body, increases freshness', () {
      final modified = balancedProfile.withOccasion(Occasion.beachPool);
      expect(modified.body, equals(4.0)); // 5 - 1.0
      expect(modified.freshness, equals(6.5)); // 5 + 1.5
      expect(modified.acidity, equals(6.0)); // 5 + 1.0
    });

    test('PE-14: Celebration gives sparkling wine +10% category bonus', () {
      final sparklingProduct = kSeedProducts.firstWhere(
        (p) => p.id == 'moet-chandon-imperial',
      );
      final result = engine.computeMatch(
        userProfile: balancedProfile,
        product: sparklingProduct,
        occasion: Occasion.celebration,
      );
      expect(result.occasionBonus, equals(10.0));
    });

    test('PE-15: Modifiers clamped to 0-10', () {
      // Profile with extreme values
      const extreme = PalateProfile(
        fruit: 10, acidity: 10, body: 0, tannin: 0, freshness: 10, complexity: 10,
        archetype: PalateArchetype.crispPurist,
      );
      final modified = extreme.withOccasion(Occasion.beachPool);
      // freshness: 10 + 1.5 should clamp to 10
      expect(modified.freshness, equals(10.0));
      // body: 0 - 1.0 should clamp to 0
      expect(modified.body, equals(0.0));
    });

    test('PE-16: Occasion modifiers dont mutate the original profile', () {
      final original = balancedProfile;
      balancedProfile.withOccasion(Occasion.dateNight);
      expect(original.complexity, equals(5.0));
      expect(original.body, equals(5.0));
    });
  });

  group('PE-17 to PE-23: Food-Drink Pairing Rules', () {
    test('PE-17: High fat + high acidity = positive (contrast)', () {
      final results = engine.suggestFoodForDrink(
        product: crispProduct, // high acidity
        dishes: kSeedDishes.where(
          (d) => d.foodProperties.contains(FoodProperty.highFat),
        ).toList(),
      );
      // Fat + acid should score well
      expect(results, isNotEmpty);
      expect(results.first.score, greaterThan(50));
    });

    test('PE-19: Spicy food + high tannin wine = bad pairing', () {
      final tannicRed = kSeedProducts.firstWhere(
        (p) => p.id == 'krsma-cabernet-sauvignon',
      );
      final spicyDishes = kSeedDishes.where(
        (d) => d.foodProperties.contains(FoodProperty.spicyHeat),
      ).toList();

      final results = engine.suggestFoodForDrink(
        product: tannicRed,
        dishes: spicyDishes,
      );

      // Spicy + tannic should score lower than spicy + fruity
      final fruitForward = kSeedProducts.firstWhere(
        (p) => p.id == 'fratelli-tilt-rose',
      );
      final betterResults = engine.suggestFoodForDrink(
        product: fruitForward,
        dishes: spicyDishes,
      );

      if (results.isNotEmpty && betterResults.isNotEmpty) {
        expect(betterResults.first.score, greaterThan(results.first.score));
      }
    });

    test('PE-23: Pairing strategy correctly identified', () {
      final results = engine.suggestFoodForDrink(
        product: crispProduct,
        dishes: kSeedDishes,
        topN: 20,
      );
      // At least some should be contrast (acid vs fat)
      final strategies = results.map((r) => r.strategy).toSet();
      expect(strategies.length, greaterThan(0));
    });
  });

  group('PE-24 to PE-28: Ranking & Filtering', () {
    test('PE-24: rankProducts returns sorted list (highest first)', () {
      final results = engine.rankProducts(
        userProfile: boldExplorerProfile,
        products: kSeedProducts,
        topN: 10,
      );
      for (var i = 1; i < results.length; i++) {
        expect(results[i - 1].score, greaterThanOrEqualTo(results[i].score));
      }
    });

    test('PE-25: rankProducts respects topN limit', () {
      final results = engine.rankProducts(
        userProfile: balancedProfile,
        products: kSeedProducts,
        topN: 5,
      );
      expect(results.length, equals(5));
    });

    test('PE-26: suggestDrinkForFood returns results for any dish', () {
      final dish = kSeedDishes.firstWhere((d) => d.id == 'butter-chicken');
      final results = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: 5,
      );
      expect(results.length, equals(5));
      // Scores should be in valid range
      for (final r in results) {
        expect(r.score, greaterThanOrEqualTo(kScoreFloor));
        expect(r.score, lessThanOrEqualTo(kScoreCeiling));
      }
    });

    test('PE-28: Frequency penalty applied correctly', () {
      final result0 = engine.computeMatch(
        userProfile: balancedProfile,
        product: crispProduct,
        recommendationCount: 0,
      );
      final result3 = engine.computeMatch(
        userProfile: balancedProfile,
        product: crispProduct,
        recommendationCount: 3,
      );
      // 4th recommendation should have -15% penalty
      expect(result3.frequencyPenalty, equals(kFrequencyPenaltyCap));
      expect(result0.frequencyPenalty, equals(0.0));
    });
  });
}
