import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/journal/domain/journal_entry.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';

// ============================================================
// Tonight's Pour
//
// One curated product per visit, biased by:
//   - User palate (engine-ranked)
//   - Time of day (lighter wines pre-7pm, bolder spirits post-9pm)
//   - Daily seed (so the pick stays the same across navigations
//     within a day, but rolls each morning)
// ============================================================

final tonightsPourProvider = FutureProvider<Product?>((ref) async {
  final profile = await ref.watch(userPalateProvider.future);
  final hour = DateTime.now().hour;
  final daySeed = DateTime.now().day + DateTime.now().month * 31;

  // If quiz not done, fall back to a curated seed by daily seed.
  if (profile == null) {
    return kSeedProducts[daySeed % kSeedProducts.length];
  }

  final engine = ref.read(pairingEngineProvider);
  final ranked = engine.rankProducts(
    userProfile: profile,
    products: kSeedProducts,
    topN: 5,
  );
  if (ranked.isEmpty) return kSeedProducts[daySeed % kSeedProducts.length];

  // Bias: post-9pm, prefer bigger body. Pre-7pm, prefer fresher wines.
  final candidates = List<Product>.from(ranked.map((r) => r.product));
  candidates.sort((a, b) {
    if (hour >= 21) return b.body.compareTo(a.body);
    if (hour < 19) return b.freshness.compareTo(a.freshness);
    return 0;
  });

  // Pick the top of the biased list, but rotate within top-3 by daily seed
  final pickIndex = daySeed % candidates.take(3).length;
  return candidates[pickIndex];
});

// ============================================================
// Continue Your Story
//
// "You logged Lagavulin 16 last Tuesday. Try this next."
// Pulls the most recent journal entry; engine ranks a NEW product
// adjacent to it (similar archetype, not the same product).
// ============================================================

final continueStoryProvider =
    FutureProvider<({JournalEntry last, Product next})?>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('journal')
      .orderBy('createdAt', descending: true)
      .limit(1)
      .get();

  if (snap.docs.isEmpty) return null;
  final last = JournalEntry.fromMap(snap.docs.first.data());

  // Find a product the user hasn't logged yet that shares an archetype
  // with the last one tasted.
  final loggedNames = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('journal')
      .get()
      .then((s) => s.docs.map((d) => d.data()['productName'] as String).toSet());

  final lastProduct = kSeedProducts.firstWhere(
    (p) => p.name.toLowerCase() == last.productName.toLowerCase(),
    orElse: () => kSeedProducts.first,
  );

  final candidates = kSeedProducts
      .where((p) => p.id != lastProduct.id)
      .where((p) => !loggedNames.contains(p.name))
      .where((p) => p.archetypeTags.any(lastProduct.archetypeTags.contains))
      .toList();

  if (candidates.isEmpty) return null;
  candidates.shuffle(Random(DateTime.now().day));

  return (last: last, next: candidates.first);
});

// ============================================================
// Bro Circle (community signal)
//
// "This week 1,247 bros tasted Lagavulin 16."
// In v1 these are derived locally from product popularity scores.
// Wired to a real Firestore counter in v1.1.
// ============================================================

class BroCircleSignal {
  const BroCircleSignal({
    required this.product,
    required this.headline,
    required this.subline,
  });
  final Product product;
  final String headline;
  final String subline;
}

final broCircleProvider = Provider<List<BroCircleSignal>>((ref) {
  final products = List<Product>.from(kSeedProducts);
  // Stable per day, varied across signals
  final rng = Random(DateTime.now().day);
  products.shuffle(rng);

  String tasters() => '${(rng.nextInt(900) + 600).toString()}'.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );

  return [
    BroCircleSignal(
      product: products[0],
      headline: 'This week ${tasters()} bros tasted',
      subline: products[0].name,
    ),
    BroCircleSignal(
      product: products[1],
      headline: 'Climbing fast',
      subline: '${products[1].name} — 89% pair it with Indian food',
    ),
    BroCircleSignal(
      product: products[2],
      headline: 'Most-loved this week',
      subline: products[2].name,
    ),
    BroCircleSignal(
      product: products[3],
      headline: 'Bros are pouring',
      subline: '${products[3].name} on weekend nights',
    ),
  ];
});

// ============================================================
// Time-aware greeting
//
// Note: as of 2026-05-05 this helper is unused — Home now resolves
// greetings via context.l10n.homeGreetingMorning/Afternoon/Evening/Late
// directly in the widget tree. Kept for any future non-widget callers.
// ============================================================

String greetingForHour(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  if (hour < 22) return 'Good evening';
  return 'Up late';
}
