import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/features/journal/domain/journal_entry.dart';
import 'package:winebro/features/wrap_up/domain/yearly_wrap_up.dart';

JournalEntry _entry({
  required String id,
  required DateTime when,
  required int rating,
  String productName = 'Sula Shiraz',
  String region = 'Nashik',
  String category = 'Wine',
  String? foodPaired,
}) {
  return JournalEntry(
    id: id,
    userId: 'u1',
    productId: id,
    productName: productName,
    category: category,
    region: region,
    rating: rating,
    createdAt: when,
    foodPaired: foodPaired,
  );
}

void main() {
  group('YearlyWrapUp.fromEntries', () {
    test('empty input → isEmpty', () {
      final w = YearlyWrapUp.fromEntries(const [], 2026);
      expect(w.isEmpty, isTrue);
      expect(w.totalTastings, 0);
    });

    test('filters to year only', () {
      final entries = [
        _entry(id: '1', when: DateTime(2025, 6, 1), rating: 4),
        _entry(id: '2', when: DateTime(2026, 6, 1), rating: 5),
        _entry(id: '3', when: DateTime(2026, 7, 1), rating: 3),
      ];
      final w = YearlyWrapUp.fromEntries(entries, 2026);
      expect(w.totalTastings, 2);
    });

    test('top product = highest count', () {
      final entries = [
        _entry(id: '1', when: DateTime(2026, 1, 1), rating: 4, productName: 'A'),
        _entry(id: '2', when: DateTime(2026, 1, 2), rating: 4, productName: 'A'),
        _entry(id: '3', when: DateTime(2026, 1, 3), rating: 4, productName: 'B'),
      ];
      final w = YearlyWrapUp.fromEntries(entries, 2026);
      expect(w.topProduct, 'A');
      expect(w.uniqueProducts, 2);
    });

    test('top pairing ignores entries without foodPaired', () {
      final entries = [
        _entry(id: '1', when: DateTime(2026, 1, 1), rating: 4, foodPaired: 'biryani'),
        _entry(id: '2', when: DateTime(2026, 1, 2), rating: 4, foodPaired: 'biryani'),
        _entry(id: '3', when: DateTime(2026, 1, 3), rating: 4),
        _entry(id: '4', when: DateTime(2026, 1, 4), rating: 4, foodPaired: 'tandoori'),
      ];
      final w = YearlyWrapUp.fromEntries(entries, 2026);
      expect(w.topPairing, 'biryani');
    });

    test('average rating', () {
      final entries = [
        _entry(id: '1', when: DateTime(2026, 1, 1), rating: 5),
        _entry(id: '2', when: DateTime(2026, 1, 2), rating: 3),
      ];
      final w = YearlyWrapUp.fromEntries(entries, 2026);
      expect(w.averageRating, 4);
    });

    test('bottlesYouLoved counts rating >= 4', () {
      final entries = [
        _entry(id: '1', when: DateTime(2026, 1, 1), rating: 5),
        _entry(id: '2', when: DateTime(2026, 1, 2), rating: 4),
        _entry(id: '3', when: DateTime(2026, 1, 3), rating: 3),
        _entry(id: '4', when: DateTime(2026, 1, 4), rating: 1),
      ];
      final w = YearlyWrapUp.fromEntries(entries, 2026);
      expect(w.bottlesYouLoved, 2);
    });

    test('longest streak: 3 consecutive days', () {
      final entries = [
        _entry(id: '1', when: DateTime(2026, 1, 1), rating: 4),
        _entry(id: '2', when: DateTime(2026, 1, 2), rating: 4),
        _entry(id: '3', when: DateTime(2026, 1, 3), rating: 4),
        _entry(id: '4', when: DateTime(2026, 1, 5), rating: 4), // gap
      ];
      final w = YearlyWrapUp.fromEntries(entries, 2026);
      expect(w.longestStreak, 3);
    });

    test('longest streak handles same-day duplicates', () {
      final entries = [
        _entry(id: '1', when: DateTime(2026, 1, 1, 9), rating: 4),
        _entry(id: '2', when: DateTime(2026, 1, 1, 21), rating: 4),
        _entry(id: '3', when: DateTime(2026, 1, 2), rating: 4),
      ];
      final w = YearlyWrapUp.fromEntries(entries, 2026);
      expect(w.longestStreak, 2);
    });
  });
}
