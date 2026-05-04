import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/services/firebase_providers.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';

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

    return engine.suggestDrinkForFood(
      userProfile: profile,
      dish: dish,
      products: products,
      topN: 5,
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

