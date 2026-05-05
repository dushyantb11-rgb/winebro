import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing_feedback/domain/pairing_aggregate.dart';

/// Engine v1.1 contract tests.
///
/// The new contract: `suggestDrinkForFood` accepts an optional
/// `feedbackAggregates` map keyed by productId. Bayesian-shrunk
/// signed bias multiplies a points cap (kFeedbackBiasCapPoints) and
/// is added to the blended score. With no aggregates, the result
/// MUST equal v1.0 behaviour exactly.
void main() {
  const engine = PairingEngine();

  const balancedProfile = PalateProfile(
    fruit: 5, acidity: 5, body: 5, tannin: 5, freshness: 5, complexity: 5,
    archetype: PalateArchetype.balancedSipper,
  );

  final dish = kSeedDishes.first;

  group('Engine v1.1 — feedback bias', () {
    test('null aggregates is a no-op (matches v1.0 behaviour exactly)', () {
      final v10 = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: 10,
      );
      final v11NoAgg = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: 10,
        feedbackAggregates: const {},
      );
      expect(v11NoAgg.length, v10.length);
      for (var i = 0; i < v10.length; i++) {
        expect(v11NoAgg[i].product.id, v10[i].product.id);
        expect(v11NoAgg[i].score, v10[i].score);
        expect(v11NoAgg[i].feedbackBonus, 0);
      }
    });

    test('a strongly positive aggregate raises a product\'s rank', () {
      final v10 = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: kSeedProducts.length,
      );

      // Pick a low-ranked product and slap 100 Yes votes on it.
      final laggard = v10[v10.length - 3].product;
      final aggregates = <String, PairingAggregate>{
        laggard.id: PairingAggregate(
          productId: laggard.id,
          dishKey: PairingAggregate.normalizeDishKey(dish.name),
          yes: 100,
          maybe: 0,
          no: 0,
        ),
      };

      final v11 = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: kSeedProducts.length,
        feedbackAggregates: aggregates,
      );

      final v10Index =
          v10.indexWhere((r) => r.product.id == laggard.id);
      final v11Index =
          v11.indexWhere((r) => r.product.id == laggard.id);
      expect(v11Index, lessThan(v10Index),
          reason: 'product with 100 Yes should rank higher than v1.0');
    });

    test('a strongly negative aggregate lowers a product\'s rank', () {
      final v10 = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: kSeedProducts.length,
      );

      // Pick the top product and slap 100 No votes on it.
      final leader = v10.first.product;
      final aggregates = <String, PairingAggregate>{
        leader.id: PairingAggregate(
          productId: leader.id,
          dishKey: PairingAggregate.normalizeDishKey(dish.name),
          yes: 0,
          maybe: 0,
          no: 100,
        ),
      };

      final v11 = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: kSeedProducts.length,
        feedbackAggregates: aggregates,
      );

      final v11Index =
          v11.indexWhere((r) => r.product.id == leader.id);
      expect(v11Index, greaterThan(0),
          reason: 'leader with 100 No should fall from rank 0');
    });

    test('low-confidence aggregates barely move the score (Bayesian shrinkage)', () {
      final v10 = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: kSeedProducts.length,
      );

      // Single Yes vote — should NOT meaningfully shift ranking.
      final aggregates = <String, PairingAggregate>{
        for (final r in v10)
          r.product.id: PairingAggregate(
            productId: r.product.id,
            dishKey: PairingAggregate.normalizeDishKey(dish.name),
            yes: 1,
            maybe: 0,
            no: 0,
          ),
      };

      final v11 = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: kSeedProducts.length,
        feedbackAggregates: aggregates,
      );

      // With a uniform prior (every product has 1 Yes), the bias is
      // identical for everyone and the order should be preserved.
      for (var i = 0; i < v10.length; i++) {
        expect(v11[i].product.id, v10[i].product.id,
            reason: 'rank $i should match — uniform low-confidence bias is neutral');
      }
    });

    test('feedback bonus stays within +/- cap', () {
      final results = engine.suggestDrinkForFood(
        userProfile: balancedProfile,
        dish: dish,
        products: kSeedProducts,
        topN: kSeedProducts.length,
        feedbackAggregates: {
          for (final p in kSeedProducts)
            p.id: PairingAggregate(
              productId: p.id,
              dishKey: PairingAggregate.normalizeDishKey(dish.name),
              yes: 1000,
              maybe: 0,
              no: 0,
            ),
        },
      );
      for (final r in results) {
        expect(r.feedbackBonus, lessThanOrEqualTo(kFeedbackBiasCapPoints + 0.01));
        expect(r.feedbackBonus, greaterThanOrEqualTo(-kFeedbackBiasCapPoints - 0.01));
      }
    });
  });

  group('PairingAggregate — shrinkage math', () {
    test('zero votes → zero bias (no community signal)', () {
      const agg = PairingAggregate(
        productId: 'x', dishKey: 'y', yes: 0, maybe: 0, no: 0,
      );
      expect(agg.signedShrunkBias(), 0);
    });

    test('1 Yes vs 100 Yes → 100 produces stronger signal', () {
      const a = PairingAggregate(
        productId: 'x', dishKey: 'y', yes: 1, maybe: 0, no: 0,
      );
      const b = PairingAggregate(
        productId: 'x', dishKey: 'y', yes: 100, maybe: 0, no: 0,
      );
      expect(b.signedShrunkBias(), greaterThan(a.signedShrunkBias()));
      expect(b.signedShrunkBias(), lessThanOrEqualTo(0.5));
    });

    test('Maybe pulls toward neutral compared to pure Yes', () {
      const allYes = PairingAggregate(
        productId: 'x', dishKey: 'y', yes: 50, maybe: 0, no: 0,
      );
      const halfMaybe = PairingAggregate(
        productId: 'x', dishKey: 'y', yes: 0, maybe: 50, no: 0,
      );
      expect(halfMaybe.signedShrunkBias(),
          lessThan(allYes.signedShrunkBias()));
      expect(halfMaybe.signedShrunkBias().abs(), lessThan(0.05));
    });
  });
}
