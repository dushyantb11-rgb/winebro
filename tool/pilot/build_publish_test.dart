// Builds tool/pilot/publish.json: the pilot's taste estimates as
// `products` rows, ready for functions/scripts/publish-pilot.js.
//
// Run from app/:  flutter test tool/pilot/build_publish_test.dart
//
// Archetype tags come from the app's own QuizEngine.classifyArchetype,
// so the published rows always match the quiz logic. Lives outside test/
// so the normal `flutter test` run skips it.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/onboarding/domain/quiz_engine.dart';

const _axes = ['fruit', 'acidity', 'body', 'tannin', 'freshness', 'complexity'];

Object? _fact(Map<String, dynamic> facts, String key) =>
    facts[key] is Map ? (facts[key] as Map)['value'] : null;

void main() {
  test('build publish.json from pilot estimates', () {
    final estimates = jsonDecode(File('tool/pilot/ai_estimates.json').readAsStringSync())
        as Map<String, dynamic>;
    final drinks = {
      for (final d in jsonDecode(File('tool/pilot/pilot_export.json').readAsStringSync()) as List)
        (d as Map<String, dynamic>)['id'] as String: d,
    };
    const engine = QuizEngine();
    final rows = <Map<String, dynamic>>[];
    var newIndex = 0;

    for (final entry in estimates.entries) {
      final e = entry.value as Map<String, dynamic>;
      final d = drinks[entry.key]!;
      final facts = (d['facts'] as Map?)?.cast<String, dynamic>() ?? {};
      final open = (d['openData'] as Map?)?.cast<String, dynamic>() ?? {};
      final catalog = (d['catalog'] as Map?)?.cast<String, dynamic>();
      final scores = {
        for (final a in PalateAxis.values) a: (e[a.name] as num).toDouble(),
      };
      final row = <String, dynamic>{
        'id': entry.key,
        'name': d['name'],
        'category': d['category'],
        for (final a in _axes) a: (e[a] as num).toInt(),
        'archetypeTags': [for (final t in engine.qualifyingArchetypes(scores)) t.name],
        'tastingNotes': e['tastingNotes'],
        'aromas': e['aromas'],
        'estimate': {
          'label': 'Estimated from published facts',
          'confidence': e['confidence'],
          'method': e['method'],
          'date': e['date'],
        },
        'provenance': 'ai-estimate',
        'verified': false,
      };

      if (catalog != null) {
        // Existing catalogue drink: keep name, region, price, ABV; keep the
        // old hand-set profile for reference.
        row['previousHandAuthored'] = {
          for (final a in _axes) a: catalog[a],
        };
      } else {
        final category = DrinkCategory.values.firstWhere((c) => c.name == d['category']);
        final grapes = _fact(facts, 'grapes');
        final bjcp = open['bjcpStyle'] as Map?;
        row['subcategory'] = grapes is List && grapes.isNotEmpty
            ? grapes.join(', ')
            : bjcp?['name'] ?? category.displayName;
        final wd = open['wikidata'] as Map?;
        row['region'] = _fact(facts, 'region') ??
            (wd?['producer'] as Map?)?['country'] ??
            (wd?['product'] as Map?)?['country'] ??
            '';
        row['price'] = 0; // pricing parked; 0 = no price shown
        final producerAbv = facts['abv'] as Map?;
        final abv = producerAbv?['value'] ?? _fact(facts, 'abvKerala') ?? _fact(facts, 'abvXWines');
        if (abv != null) {
          row['abv'] = (abv as num).toDouble();
          row['abvSource'] = producerAbv?['source'] ??
              (_fact(facts, 'abvKerala') != null ? 'Kerala BEVCO price list' : 'X-Wines (CC0)');
        }
        row['sortOrder'] = 1000 + newIndex++;
        row['source'] = 'winebro-pilot';
      }
      rows.add(row);
    }

    expect(rows.length, estimates.length);
    File('tool/pilot/publish.json')
        .writeAsStringSync(const JsonEncoder.withIndent(' ').convert(rows));
  });
}
