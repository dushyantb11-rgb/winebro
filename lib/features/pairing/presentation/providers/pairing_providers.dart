import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/preview/drafts_preview.dart';
import 'package:winebro/core/preview/preview_overrides.dart';
import 'package:winebro/core/services/firebase_providers.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing_feedback/data/pairing_aggregate_repository.dart';
import 'package:winebro/features/pairing_feedback/domain/pairing_aggregate.dart';

final pairingEngineProvider = Provider((_) => const PairingEngine());

final userPalateProvider = FutureProvider<PalateProfile?>((ref) async {
  // Console preview can force a test palate ("try as Crisp Purist").
  final forced = ref.watch(previewPalateProvider);
  if (forced != null) return forced;
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
  T Function(Map<String, dynamic>) fromMap, {
  PreviewOverrides overrides = PreviewOverrides.none,
}) {
  return FirebaseFirestore.instance
      .collection(collection)
      .orderBy('sortOrder')
      .snapshots()
      .map((snap) {
    final raw = overrides.applyTo(
      collection,
      [for (final d in snap.docs) {...d.data(), 'id': d.id}],
    );
    final items = <T>[];
    for (final data in raw) {
      // Archived rows stay in Firestore for history but never reach the app.
      if (data['archived'] == true) continue;
      try {
        items.add(fromMap(data));
      } on Object catch (e) {
        debugPrint('Skipping $collection/${data['id']}: $e');
      }
    }
    return items;
  });
}

final _remoteProductsProvider = StreamProvider<List<Product>>(
  (ref) => _catalogStream('products', Product.fromMap,
      overrides: ref.watch(effectiveOverridesProvider)),
);

final _remoteDishesProvider = StreamProvider<List<Dish>>(
  (ref) => _catalogStream('dishes', Dish.fromMap,
      overrides: ref.watch(effectiveOverridesProvider)),
);

/// Where the catalogue stands. Screens show a [CatalogStateBanner] for
/// anything other than [CatalogStatus.ready]; the bundled seed lists are
/// never substituted silently (Firestore's own cache covers offline use).
enum CatalogStatus { loading, ready, empty, error }

final catalogStatusProvider = Provider<CatalogStatus>((ref) {
  final products = ref.watch(_remoteProductsProvider);
  final dishes = ref.watch(_remoteDishesProvider);
  if (products.hasError || dishes.hasError) return CatalogStatus.error;
  if (products.isLoading || dishes.isLoading) return CatalogStatus.loading;
  if ((products.valueOrNull ?? const []).isEmpty) return CatalogStatus.empty;
  return CatalogStatus.ready;
});

/// Re-subscribes to both catalogue streams after an error.
final catalogRefreshProvider = Provider<void Function()>((ref) => () {
      ref.invalidate(_remoteProductsProvider);
      ref.invalidate(_remoteDishesProvider);
    });

/// Drink catalogue from Firestore `products`. Empty while loading or on
/// error; see [catalogStatusProvider].
final allProductsProvider = Provider<List<Product>>(
  (ref) => ref.watch(_remoteProductsProvider).valueOrNull ?? const [],
);

/// Dish catalogue from Firestore `dishes`. Same rules as [allProductsProvider].
final allDishesProvider = Provider<List<Dish>>(
  (ref) => ref.watch(_remoteDishesProvider).valueOrNull ?? const [],
);

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

