import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';

void main() {
  const engine = PairingEngine();
  final butterChicken = kSeedDishes.firstWhere((d) => d.id == 'butter-chicken');
  final sulaSb = kSeedProducts.firstWhere((p) => p.id == 'sula-sauvignon-blanc');
  const profile = PalateProfile(
    fruit: 5, acidity: 5, body: 5, tannin: 5, freshness: 5, complexity: 5,
    archetype: PalateArchetype.balancedSipper,
  );

  test('CP-01: drink results carry the hand-written Bro Tip when curated', () {
    final results = engine.suggestDrinkForFood(
      userProfile: profile,
      dish: butterChicken,
      products: [sulaSb],
    );
    final curated =
        butterChicken.pairings.firstWhere((p) => p.productId == sulaSb.id);
    expect(results.single.broTip, curated.broTip);
  });

  test('CP-02: food results use the curated tip instead of the template', () {
    final results = engine.suggestFoodForDrink(
      product: sulaSb,
      dishes: [butterChicken],
    );
    expect(results.single.isCurated, isTrue);
    expect(results.single.explanation, contains('Sauvignon Blanc'));
  });

  test('CP-03: pairs without a curated entry keep the template text', () {
    final other = kSeedProducts.firstWhere((p) =>
        !butterChicken.pairings.any((c) => c.productId == p.id));
    final food = engine.suggestFoodForDrink(product: other, dishes: [butterChicken]);
    expect(food.single.isCurated, isFalse);
    final drink = engine.suggestDrinkForFood(
      userProfile: profile, dish: butterChicken, products: [other]);
    expect(drink.single.broTip, isNull);
  });
}
