import 'package:winebro/features/journal/domain/journal_entry.dart';

/// User's year in tastings — pure derivation from JournalEntry list.
/// Built once per visit to Wrap-up; no Firestore writes.
class YearlyWrapUp {
  const YearlyWrapUp({
    required this.year,
    required this.totalTastings,
    required this.uniqueProducts,
    required this.topProduct,
    required this.topRegion,
    required this.topPairing,
    required this.topCategory,
    required this.averageRating,
    required this.longestStreak,
    required this.bottlesYouLoved,
  });

  final int year;
  final int totalTastings;
  final int uniqueProducts;
  final String? topProduct;
  final String? topRegion;
  final String? topPairing;
  final String? topCategory;
  final double averageRating;
  final int longestStreak;
  final int bottlesYouLoved; // rating >= 4

  bool get isEmpty => totalTastings == 0;

  /// Build from a list of entries. Filters to the given year.
  static YearlyWrapUp fromEntries(List<JournalEntry> entries, int year) {
    final yearEntries = entries
        .where((e) => e.createdAt.year == year)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (yearEntries.isEmpty) {
      return YearlyWrapUp(
        year: year,
        totalTastings: 0,
        uniqueProducts: 0,
        topProduct: null,
        topRegion: null,
        topPairing: null,
        topCategory: null,
        averageRating: 0,
        longestStreak: 0,
        bottlesYouLoved: 0,
      );
    }

    final productCounts = <String, int>{};
    final regionCounts = <String, int>{};
    final pairingCounts = <String, int>{};
    final categoryCounts = <String, int>{};
    var ratingSum = 0;
    var loved = 0;

    for (final e in yearEntries) {
      productCounts[e.productName] = (productCounts[e.productName] ?? 0) + 1;
      if (e.region.isNotEmpty) {
        regionCounts[e.region] = (regionCounts[e.region] ?? 0) + 1;
      }
      if (e.foodPaired != null && e.foodPaired!.isNotEmpty) {
        pairingCounts[e.foodPaired!] =
            (pairingCounts[e.foodPaired!] ?? 0) + 1;
      }
      categoryCounts[e.category] = (categoryCounts[e.category] ?? 0) + 1;
      ratingSum += e.rating;
      if (e.rating >= 4) loved++;
    }

    String? topOf(Map<String, int> m) {
      if (m.isEmpty) return null;
      String? top;
      var topCount = 0;
      for (final entry in m.entries) {
        if (entry.value > topCount) {
          top = entry.key;
          topCount = entry.value;
        }
      }
      return top;
    }

    // Longest streak: count the longest run of consecutive calendar
    // days where at least one entry exists.
    final daysActive = yearEntries
        .map((e) => DateTime(
              e.createdAt.year,
              e.createdAt.month,
              e.createdAt.day,
            ))
        .toSet()
        .toList()
      ..sort();

    var longestStreak = 0;
    var currentStreak = 0;
    DateTime? prev;
    for (final d in daysActive) {
      if (prev == null || d.difference(prev).inDays == 1) {
        currentStreak += 1;
      } else if (d == prev) {
        // duplicate — defensive
      } else {
        currentStreak = 1;
      }
      if (currentStreak > longestStreak) longestStreak = currentStreak;
      prev = d;
    }

    return YearlyWrapUp(
      year: year,
      totalTastings: yearEntries.length,
      uniqueProducts: productCounts.length,
      topProduct: topOf(productCounts),
      topRegion: topOf(regionCounts),
      topPairing: topOf(pairingCounts),
      topCategory: topOf(categoryCounts),
      averageRating: ratingSum / yearEntries.length,
      longestStreak: longestStreak,
      bottlesYouLoved: loved,
    );
  }
}
