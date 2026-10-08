import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/features/pairing/domain/open_facts.dart';

void main() {
  group('OpenFacts.fromOpenData', () {
    test('OF-01: no open data gives an empty result', () {
      expect(OpenFacts.fromOpenData(null).isEmpty, isTrue);
      expect(OpenFacts.fromOpenData(const {}).isEmpty, isTrue);
    });

    test('OF-02: matching ABV is shown once with a "matches" tag', () {
      final f = OpenFacts.fromOpenData(const {
        'wikidata': {
          'product': {'name': 'Monkey Shoulder', 'founded': 2003, 'abv': 40},
        },
      }, ourAbv: 40);
      final abv = f.facts.firstWhere((x) => x.kind == OpenFactKind.alcohol);
      expect(abv.value, '40%');
      expect(abv.agreement, FactAgreement.matchesOurs);
      expect(abv.source, 'Wikidata');
      final brand = f.facts.firstWhere((x) => x.kind == OpenFactKind.brand);
      expect(brand.value, 'Monkey Shoulder · since 2003');
    });

    test('OF-03: ABV 0.5 or more away is shown next to ours as "differs"',
        () {
      final f = OpenFacts.fromOpenData(const {
        'xwines': {'abv': 13.5, 'pairsWith': ['Shellfish']},
      }, ourAbv: 12.5);
      final abv = f.facts.firstWhere((x) => x.kind == OpenFactKind.alcohol);
      expect(abv.value, '12.5% ours · 13.5% X-Wines');
      expect(abv.agreement, FactAgreement.differs);
      final pairs = f.facts.firstWhere((x) => x.kind == OpenFactKind.pairsWith);
      expect(pairs.chips, ['Shellfish']);
    });

    test('OF-04: BJCP style shows name, id and ranges', () {
      final f = OpenFacts.fromOpenData(const {
        'bjcpStyle': {
          'styleId': '24A',
          'name': 'Witbier',
          'abv': {'min': 4.5, 'max': 5.5},
          'ibu': {'min': 8, 'max': 20},
        },
      });
      final style = f.facts.single;
      expect(style.kind, OpenFactKind.beerStyle);
      expect(style.value, 'Witbier (BJCP 24A) · 4.5–5.5% ABV · 8–20 IBU');
    });

    test('OF-05: Commons photo wins over Open Food Facts; credit kept', () {
      final both = OpenFacts.fromOpenData(const {
        'bottlePhoto': {
          'imageUrl': 'https://commons/a.jpg',
          'author': 'DYVER',
          'licence': 'CC BY-SA 4.0',
        },
        'openFoodFacts': {'imageUrl': 'https://off/b.jpg'},
      });
      expect(both.photo!.imageUrl, 'https://commons/a.jpg');
      expect(both.photo!.credit, 'DYVER · CC BY-SA 4.0 · Wikimedia Commons');

      final offOnly = OpenFacts.fromOpenData(const {
        'openFoodFacts': {'imageUrl': 'https://off/b.jpg'},
      });
      expect(offOnly.photo!.credit,
          'Open Food Facts contributors · CC BY-SA 3.0');
    });

    test('OF-06: producer is preferred over brand', () {
      final f = OpenFacts.fromOpenData(const {
        'wikidata': {
          'producer': {'name': 'Hoegaarden Brewery', 'country': 'Belgium', 'founded': 1966},
          'product': {'name': 'Hoegaarden', 'founded': 1445},
        },
      });
      expect(f.facts.single.kind, OpenFactKind.producer);
      expect(f.facts.single.value, 'Hoegaarden Brewery · Belgium · since 1966');
    });
  });
}
