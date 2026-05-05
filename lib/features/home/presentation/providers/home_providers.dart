import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/home/domain/community_signal.dart';
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
// Restock surface
//
// Surfaces buy-again journal entries aged 28-35 days as a "time
// to restock" Home tile. Window is intentionally narrow:
//   < 28 days → too soon, the bottle isn't gone
//   > 35 days → already passed; CF-10's Sunday push catches the tail
// Generates the D7 "Restocking behaviour" data asset every time
// the user taps Reorder vs dismisses.
// ============================================================

final restockProvider = FutureProvider<JournalEntry?>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final now = DateTime.now();
  final minCreated = now.subtract(const Duration(days: 35));
  final maxCreated = now.subtract(const Duration(days: 28));

  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('journal')
      .where('buyAgain', isEqualTo: true)
      .where('createdAt', isGreaterThanOrEqualTo: minCreated.toIso8601String())
      .where('createdAt', isLessThan: maxCreated.toIso8601String())
      .orderBy('createdAt')
      .limit(1)
      .get();

  if (snap.docs.isEmpty) return null;
  return JournalEntry.fromMap(snap.docs.first.data());
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

/// Reads the top community signals written by CF-11 nightly. Up to
/// 12 docs ordered by tastersThisWeek desc — the consumer composes
/// the 4 most interesting (climbing / loved / top pairer / volume).
final communitySignalsProvider =
    StreamProvider<List<CommunitySignal>>((ref) {
  return FirebaseFirestore.instance
      .collection('community_signals')
      .orderBy('tastersThisWeek', descending: true)
      .limit(12)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => CommunitySignal.fromMap(d.data())).toList());
});

/// Bro Circle on Home — composed signals shown in the horizontal
/// scroller. Replaces the synthetic v1 placeholder. Strategy:
///   1. If CF-11 has produced data, surface 4 real signals
///      (volume / climbing / loved / top-pairing).
///   2. If the collection is empty (cold start / fresh deploy),
///      fall back to a "be the first to taste" ribbon over our
///      seed products so Day-1 users still see something useful.
final broCircleProvider = Provider<List<BroCircleSignal>>((ref) {
  final signalsAsync = ref.watch(communitySignalsProvider);
  final signals = signalsAsync.value ?? const <CommunitySignal>[];

  Product? seedProductFor(String id) =>
      kSeedProducts.where((p) => p.id == id).firstOrNull;

  if (signals.isNotEmpty) {
    final composed = <BroCircleSignal>[];

    // Pick 1: highest taster volume.
    final topVolume = signals.first;
    final p1 = seedProductFor(topVolume.productId);
    if (p1 != null) {
      composed.add(BroCircleSignal(
        product: p1,
        headline: 'This week ${_formatCount(topVolume.tastersThisWeek)} '
            'bro${topVolume.tastersThisWeek == 1 ? '' : 's'} tasted',
        subline: topVolume.productName,
      ));
    }

    // Pick 2: climbing fastest (must be different product).
    final climbing = signals
        .where((s) => s.isClimbing && s.productId != topVolume.productId)
        .firstOrNull;
    if (climbing != null) {
      final p = seedProductFor(climbing.productId);
      if (p != null) {
        composed.add(BroCircleSignal(
          product: p,
          headline: 'Climbing fast',
          subline:
              '${climbing.productName} — ${(climbing.climbingScore * 100).round()}% week-over-week',
        ));
      }
    }

    // Pick 3: most-loved (≥70% rated 4-5).
    final loved = signals
        .where((s) =>
            s.isLoved &&
            !composed.any((c) => c.product.id == s.productId))
        .firstOrNull;
    if (loved != null) {
      final p = seedProductFor(loved.productId);
      if (p != null) {
        composed.add(BroCircleSignal(
          product: p,
          headline: 'Most-loved this week',
          subline:
              '${loved.productName} — ${(loved.lovedRate * 100).round()}% rate it 4★+',
        ));
      }
    }

    // Pick 4: most distinctive top-pairing (D1 surface).
    final paired = signals
        .where((s) =>
            s.topPairing != null &&
            s.topPairingShare >= 0.4 &&
            !composed.any((c) => c.product.id == s.productId))
        .firstOrNull;
    if (paired != null) {
      final p = seedProductFor(paired.productId);
      if (p != null) {
        composed.add(BroCircleSignal(
          product: p,
          headline: 'Bros are pouring',
          subline:
              '${paired.productName} with ${paired.topPairing}',
        ));
      }
    }

    if (composed.length >= 3) return composed;
    // If the live data was thin (fewer than 3 distinct signals), fall
    // through to the seed-product fallback below.
  }

  // Cold-start fallback — shown until CF-11 has produced enough data.
  // Same 4 cards but framed as "be the first" rather than fake numbers.
  final products = List<Product>.from(kSeedProducts);
  final rng = Random(DateTime.now().day);
  products.shuffle(rng);

  return [
    BroCircleSignal(
      product: products[0],
      headline: 'Be the first to log',
      subline: products[0].name,
    ),
    BroCircleSignal(
      product: products[1],
      headline: 'Bro is curious about',
      subline: products[1].name,
    ),
    BroCircleSignal(
      product: products[2],
      headline: 'Try this tonight',
      subline: products[2].name,
    ),
    BroCircleSignal(
      product: products[3],
      headline: 'Bro recommends',
      subline: products[3].name,
    ),
  ];
});

String _formatCount(int n) {
  return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );
}

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
