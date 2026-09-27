import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/services/firebase_providers.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/product.dart';
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

/// Reads a read-only catalogue collection, ordered by `sortOrder`.
/// A document that fails to parse is skipped, so one bad row cannot
/// empty the whole list.
Stream<List<T>> _catalogStream<T>(
  String collection,
  T Function(Map<String, dynamic>) fromMap,
) {
  return FirebaseFirestore.instance
      .collection(collection)
      .orderBy('sortOrder')
      .snapshots()
      .map((snap) {
    final items = <T>[];
    for (final doc in snap.docs) {
      try {
        items.add(fromMap(doc.data()));
      } on Object catch (e) {
        debugPrint('Skipping $collection/${doc.id}: $e');
      }
    }
    return items;
  });
}

final _remoteProductsProvider = StreamProvider<List<Product>>(
  (ref) => _catalogStream('products', Product.fromMap),
);

final _remoteDishesProvider = StreamProvider<List<Dish>>(
  (ref) => _catalogStream('dishes', Dish.fromMap),
);

/// Drink catalogue. Firestore `products` is the source of truth. The
/// bundled seed list is used only until the first snapshot arrives, when
/// the collection is empty, or when it cannot be read.
final allProductsProvider = Provider<List<Product>>((ref) {
  final remote = ref.watch(_remoteProductsProvider).valueOrNull;
  return (remote == null || remote.isEmpty) ? kSeedProducts : remote;
});

/// Dish catalogue. Same source rules as [allProductsProvider].
final allDishesProvider = Provider<List<Dish>>((ref) {
  final remote = ref.watch(_remoteDishesProvider).valueOrNull;
  return (remote == null || remote.isEmpty) ? kSeedDishes : remote;
});

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

