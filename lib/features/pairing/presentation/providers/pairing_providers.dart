import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/services/firebase_providers.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing_feedback/data/pairing_aggregate_repository.dart';
import 'package:winebro/features/pairing_feedback/domain/pairing_aggregate.dart';

final pairingEngineProvider = Provider((_) => const PairingEngine());

final userPalateProvider = FutureProvider<PalateProfile?>((ref) async {
  final docRef = ref.watch(userDocRefProvider);
  if (docRef == null) return null;

  final doc = await docRef.get();
  final data = (doc.data() as Map<String, dynamic>?)?['palateProfile']
      as Map<String, dynamic>?;
  return data != null ? PalateProfile.fromMap(data) : null;
});

final allProductsProvider = Provider((_) => kSeedProducts);

final allDishesProvider = Provider((_) => kSeedDishes);

final groupedDishesProvider =
    Provider<Map<FoodCategory, List<Dish>>>((ref) {
  final dishes = ref.read(allDishesProvider);
  final grouped = <FoodCategory, List<Dish>>{};
  for (final dish in dishes) {
    grouped.putIfAbsent(dish.category, () => []).add(dish);
  }
  return grouped;
});

final drinkForFoodProvider = FutureProvider.family<List<PairingResult>, String>(
  (ref, dishId) async {
    final profile = await ref.watch(userPalateProvider.future);
    if (profile == null) return [];

    final engine = ref.read(pairingEngineProvider);
    final products = ref.read(allProductsProvider);
    final dishes = ref.read(allDishesProvider);
    final dish = dishes.firstWhere((d) => d.id == dishId);

    // Engine v1.1 — fold community feedback (D6) into the ranking.
    // We fetch only the top ~30 products' aggregates rather than all
    // ~100; pre-rank by engine v1.0 first to keep the read small.
    final v10 = engine.suggestDrinkForFood(
      userProfile: profile,
      dish: dish,
      products: products,
      topN: 30,
    );

    final aggregates = await ref
        .read(pairingAggregateRepositoryProvider)
        .aggregatesForDish(
          productIds: v10.map((r) => r.product.id).toList(),
          dishKey: PairingAggregate.normalizeDishKey(dish.name),
        );

    return engine.suggestDrinkForFood(
      userProfile: profile,
      dish: dish,
      products: products,
      topN: 5,
      feedbackAggregates: aggregates,
    );
  },
);

final foodForDrinkProvider =
    FutureProvider.family<List<FoodPairingResult>, String>(
  (ref, productId) async {
    final engine = ref.read(pairingEngineProvider);
    final products = ref.read(allProductsProvider);
    final dishes = ref.read(allDishesProvider);
    final product = products.firstWhere((p) => p.id == productId);

    return engine.suggestFoodForDrink(
      product: product,
      dishes: dishes,
      topN: 5,
    );
  },
);

final occasionPairingProvider =
    FutureProvider.family<List<PairingResult>, Occasion>(
  (ref, occasion) async {
    final profile = await ref.watch(userPalateProvider.future);
    if (profile == null) return [];

    final engine = ref.read(pairingEngineProvider);
    final products = ref.read(allProductsProvider);

    return engine.rankProducts(
      userProfile: profile,
      products: products,
      occasion: occasion,
      topN: 5,
    );
  },
);

