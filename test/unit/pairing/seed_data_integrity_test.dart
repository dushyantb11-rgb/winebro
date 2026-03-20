import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/features/aroma_wheel/domain/aroma_taxonomy.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';

void main() {
  group('SD-01 to SD-10: Seed Data Integrity', () {
    test('SD-01: All 50 products have unique IDs', () {
      final ids = kSeedProducts.map((p) => p.id).toSet();
      expect(ids.length, equals(kSeedProducts.length));
      expect(kSeedProducts.length, equals(50));
    });

    test('SD-02: All 52 dishes have unique IDs', () {
      final ids = kSeedDishes.map((d) => d.id).toSet();
      expect(ids.length, equals(kSeedDishes.length));
      expect(kSeedDishes.length, equals(52));
    });

    test('SD-03: All product axis scores within 0-10', () {
      for (final p in kSeedProducts) {
        expect(p.fruit, inInclusiveRange(0, 10),
            reason: '${p.name} fruit out of range');
        expect(p.acidity, inInclusiveRange(0, 10),
            reason: '${p.name} acidity out of range');
        expect(p.body, inInclusiveRange(0, 10),
            reason: '${p.name} body out of range');
        expect(p.tannin, inInclusiveRange(0, 10),
            reason: '${p.name} tannin out of range');
        expect(p.freshness, inInclusiveRange(0, 10),
            reason: '${p.name} freshness out of range');
        expect(p.complexity, inInclusiveRange(0, 10),
            reason: '${p.name} complexity out of range');
      }
    });

    test('SD-04: All dish pairings reference valid product IDs', () {
      final productIds = kSeedProducts.map((p) => p.id).toSet();
      for (final dish in kSeedDishes) {
        for (final pairing in dish.pairings) {
          expect(
            productIds.contains(pairing.productId),
            isTrue,
            reason:
                '${dish.name} references unknown product: ${pairing.productId}',
          );
        }
      }
    });

    test('SD-05: All products have non-empty tasting notes', () {
      for (final p in kSeedProducts) {
        expect(p.tastingNotes.isNotEmpty, isTrue,
            reason: '${p.name} has empty tasting notes');
        expect(p.tastingNotes.length, greaterThan(20),
            reason: '${p.name} tasting notes too short');
      }
    });

    test('SD-06: All products have at least 1 aroma', () {
      for (final p in kSeedProducts) {
        expect(p.aromas.isNotEmpty, isTrue,
            reason: '${p.name} has no aromas');
      }
    });

    test('SD-07: All dishes have at least 1 food property', () {
      for (final d in kSeedDishes) {
        expect(d.foodProperties.isNotEmpty, isTrue,
            reason: '${d.name} has no food properties');
      }
    });

    test('SD-08: All dishes have at least 2 pairings', () {
      for (final d in kSeedDishes) {
        expect(d.pairings.length, greaterThanOrEqualTo(2),
            reason: '${d.name} has fewer than 2 pairings');
      }
    });

    test('SD-09: No duplicate product names', () {
      final names = kSeedProducts.map((p) => p.name).toSet();
      expect(names.length, equals(kSeedProducts.length));
    });

    test('SD-10: All dish pairing scores within 40-99', () {
      for (final d in kSeedDishes) {
        for (final p in d.pairings) {
          expect(p.score, inInclusiveRange(40, 99),
              reason: '${d.name} → ${p.productId} score ${p.score} out of range');
        }
      }
    });
  });

  group('AW-05 to AW-06: Aroma Wheel Integrity', () {
    test('AW-05: Indian-specific aromas present', () {
      final allAromas = kAromaWheel
          .expand((c) => c.allAromas)
          .map((a) => a.toLowerCase())
          .toSet();
      expect(allAromas.contains('elaichi (cardamom)'), isTrue);
      expect(allAromas.contains('tamarind (imli)'), isTrue);
      expect(allAromas.contains('jaggery'), isTrue);
      expect(allAromas.contains('kokum'), isTrue);
      expect(allAromas.contains('curry leaf'), isTrue);
      expect(allAromas.contains('ghee'), isTrue);
      expect(allAromas.contains('rose water'), isTrue);
    });

    test('AW-06: Total aroma count > 100', () {
      final count = kAromaWheel.fold<int>(
        0,
        (sum, cat) => sum + cat.allAromas.length,
      );
      expect(count, greaterThan(100));
    });
  });
}
