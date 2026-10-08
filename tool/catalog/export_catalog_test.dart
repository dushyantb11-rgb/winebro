// Writes the bundled seed catalogue to tool/catalog/catalog.json so
// functions/scripts/seed-catalog.js can upload it to Firestore.
//
// Run from app/:  flutter test tool/catalog/export_catalog_test.dart
//
// Lives outside test/ so the normal `flutter test` run skips it.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';

void main() {
  test('export seed catalogue to JSON', () {
    final productIds = <String>{};
    for (final p in kSeedProducts) {
      expect(productIds.add(p.id), isTrue, reason: 'duplicate product ${p.id}');
    }
    final dishIds = <String>{};
    for (final d in kSeedDishes) {
      expect(dishIds.add(d.id), isTrue, reason: 'duplicate dish ${d.id}');
    }

    final catalog = {
      'products': [
        for (var i = 0; i < kSeedProducts.length; i++)
          {...kSeedProducts[i].toMap(), 'sortOrder': i},
      ],
      'dishes': [
        for (var i = 0; i < kSeedDishes.length; i++)
          {...kSeedDishes[i].toMap(), 'sortOrder': i},
      ],
    };
    File('tool/catalog/catalog.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(catalog),
    );
  });
}
