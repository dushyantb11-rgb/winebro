import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/scanner/domain/label_matcher.dart';

void main() {
  const matcher = LabelMatcher();

  String? matchId(String label) => matcher.match(label, kSeedProducts)?.product.id;

  group('LabelMatcher', () {
    test('LM-01: brand and variety on separate lines, no "Vineyards"', () {
      expect(
        matchId('SULA\nNASHIK VALLEY\nSAUVIGNON BLANC\n2023 750 ml 12.5% vol'),
        'sula-sauvignon-blanc',
      );
    });

    test('LM-02: same brand, other variety does not match the wrong wine',
        () {
      expect(matchId('SULA\nSHIRAZ\nNashik'), 'sula-shiraz');
    });

    test('LM-03: OCR slip in one word still matches', () {
      expect(matchId('KRSMA ESTATES CABERNET SAUV1GNON Hampi Hills'),
          'krsma-cabernet-sauvignon');
    });

    test('LM-04: age numbers must match exactly', () {
      expect(matchId('LAGAVULIN 16 YEAR OLD Islay single malt'), 'lagavulin-16');
      expect(matchId('GLENFIDDICH 18 YEAR OLD'), isNull);
    });

    test('LM-05: long label text does not dilute the score', () {
      const legal = 'Contains sulphites. Consume responsibly. For sale in '
          'Maharashtra only. Statutory warning: consumption of alcohol is '
          'injurious to health. Bottled by the producer. Net content 750 ml.';
      expect(matchId('Kim Crawford Marlborough Sauvignon Blanc $legal'),
          'kim-crawford-sauvignon-blanc');
    });

    test('LM-06: unknown label gives no match; score is reported', () {
      expect(matcher.match('Random Craft Lager 330ml', kSeedProducts), isNull);
      final m = matcher.match('Hoegaarden', kSeedProducts)!;
      expect(m.product.id, 'hoegaarden');
      expect(m.percent, 100);
    });
  });
}
