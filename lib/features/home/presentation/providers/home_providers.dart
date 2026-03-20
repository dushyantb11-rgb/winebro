import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';

final brosPickProvider = FutureProvider<Product?>((ref) async {
  final profile = await ref.watch(userPalateProvider.future);
  if (profile == null) return kSeedProducts.first;

  final engine = ref.read(pairingEngineProvider);

  final results = engine.rankProducts(
    userProfile: profile,
    products: kSeedProducts,
    topN: 1,
  );

  return results.isNotEmpty ? results.first.product : kSeedProducts.first;
});

final trendingProductsProvider = Provider<List<Product>>((ref) {
  final sorted = List<Product>.from(kSeedProducts)
    ..sort((a, b) {
      final aScore = a.complexity * 1.5 + a.body + a.fruit * 0.5;
      final bScore = b.complexity * 1.5 + b.body + b.fruit * 0.5;
      return bScore.compareTo(aScore);
    });
  return sorted.take(10).toList();
});

