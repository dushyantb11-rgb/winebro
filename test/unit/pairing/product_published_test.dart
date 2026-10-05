import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/features/pairing/domain/product.dart';

Map<String, dynamic> _row({double price = 0, String region = '', Object? estimate, bool? verified}) => {
      'id': 'x', 'name': 'X', 'category': 'whisky', 'subcategory': 'Whisky',
      'region': region, 'price': price, 'fruit': 5, 'acidity': 3, 'body': 6,
      'tannin': 3, 'freshness': 3, 'complexity': 5, 'archetypeTags': ['balancedSipper'],
      'tastingNotes': 'n', 'aromas': ['a'],
      if (estimate != null) 'estimate': estimate,
      if (verified != null) 'verified': verified,
    };

void main() {
  test('PP-01: price 0 means no price', () {
    expect(Product.fromMap(_row()).hasPrice, isFalse);
    expect(Product.fromMap(_row(price: 750)).hasPrice, isTrue);
  });

  test('PP-02: subtitle skips an empty region', () {
    expect(Product.fromMap(_row()).subtitle, 'Whisky');
    expect(Product.fromMap(_row(region: 'India')).subtitle, 'Whisky · India');
  });

  test('PP-03: estimate confidence and verified are read', () {
    final p = Product.fromMap(_row(estimate: {'confidence': 'medium'}));
    expect(p.estimateConfidence, 'medium');
    expect(p.verified, isFalse);
    expect(Product.fromMap(_row(verified: true)).verified, isTrue);
    expect(Product.fromMap(_row()).estimateConfidence, isNull);
  });
}
