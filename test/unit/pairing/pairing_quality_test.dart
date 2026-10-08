import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';

void main() {
  const engine = PairingEngine();
  const neutral = PalateProfile(
    fruit: 5, acidity: 5, body: 5, tannin: 5, freshness: 5, complexity: 5,
    archetype: PalateArchetype.balancedSipper,
  );
  final butterChicken = kSeedDishes.firstWhere((d) => d.id == 'butter-chicken');

  test('PQ-01: for Butter Chicken the top drink is a hand-written pairing', () {
    final top = engine
        .suggestDrinkForFood(userProfile: neutral, dish: butterChicken, products: kSeedProducts)
        .first;
    final curatedIds = butterChicken.pairings.map((p) => p.productId).toSet();
    expect(curatedIds, contains(top.product.id));
  });

  test('PQ-02: food results for a drink are spread out, not tied', () {
    final sulaSb = kSeedProducts.firstWhere((p) => p.id == 'sula-sauvignon-blanc');
    final top10 = engine.suggestFoodForDrink(product: sulaSb, dishes: kSeedDishes, topN: 10);
    final distinct = top10.map((r) => r.matchPercent).toSet();
    // Equal scores only where dishes trigger exactly the same rules.
    expect(distinct.length, greaterThanOrEqualTo(3));
    expect(top10.first.score, greaterThan(top10.last.score));
  });

  test('PQ-03: a dry, crisp wine is never described as sweet for spicy food', () {
    final dryCrisp = kSeedProducts.firstWhere((p) => p.acidity >= 6 && p.fruit < 7 && p.tannin <= 4);
    final spicy = kSeedDishes.where((d) =>
        d.foodProperties.contains(FoodProperty.spicyHeat) &&
        !d.pairings.any((c) => c.productId == dryCrisp.id));
    for (final r in engine.suggestFoodForDrink(product: dryCrisp, dishes: spicy.toList(), topN: 50)) {
      if (!r.isCurated) expect(r.explanation.toLowerCase(), isNot(contains('sweet')));
    }
  });
}
