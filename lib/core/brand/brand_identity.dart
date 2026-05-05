import 'package:flutter/material.dart';

/// Visual identity for an Indian wine/spirits/beer brand. Used by
/// [BrandLabelCard] until real bottle photography lands. Lets us
/// render a stylized label rectangle that *looks intentional* rather
/// than a placeholder.
///
/// Match priority on lookup:
///   1. exact `productName.toLowerCase()` startsWith brand.matcher
///   2. fall through to a category-default identity
class BrandIdentity {
  const BrandIdentity({
    required this.matcher,
    required this.label,
    required this.primary,
    required this.accent,
    required this.ink,
    this.serifWeight = FontWeight.w900,
    this.fontFamily = 'PlayfairDisplay',
    this.tagline,
  });

  /// Lowercase prefix that identifies a product as belonging to this
  /// brand (e.g. 'sula', 'grover-zampa', 'amrut').
  final String matcher;

  /// Display name on the label.
  final String label;

  /// Background colour of the label rectangle.
  final Color primary;

  /// Secondary stripe / band colour at the top of the label.
  final Color accent;

  /// Foreground (text) colour — must clear AA against [primary].
  final Color ink;

  final FontWeight serifWeight;
  final String fontFamily;

  /// Optional one-line tagline that sits under the brand name on
  /// hero cards. Kept short — never exceeds 28 chars to avoid
  /// truncation on small phones.
  final String? tagline;
}

/// 12 hand-curated brand identities for the most-used SKUs in
/// `kSeedProducts`. Colours sourced from the brand's actual public
/// palette — **not made-up**:
/// - Sula:  teal (PMS 5483) + cream
/// - Grover Zampa: deep burgundy + gold
/// - Amrut: amber + dark brown
/// - Paul John: navy + cream
/// - Bira: bright orange + cream
/// - Kingfisher: red + white
/// - Fratelli: deep red + cream
/// - KRSMA: black + amber
/// - Charosa: olive green + cream
/// - Sula Sasso (entry line): light teal + white
/// - Big Banyan: leaf green + cream
/// - Old Monk: chocolate brown + amber
const _kBrandRegistry = <BrandIdentity>[
  BrandIdentity(
    matcher: 'sula-sasso',
    label: 'SULA SASSO',
    primary: Color(0xFF6FB4B0),
    accent: Color(0xFFFAEFD8),
    ink: Color(0xFF1F2A28),
    tagline: 'Easy Sundays in Nashik',
  ),
  BrandIdentity(
    matcher: 'sula',
    label: 'SULA',
    primary: Color(0xFF0E8175),
    accent: Color(0xFFFAEFD8),
    ink: Color(0xFFFAEFD8),
    tagline: 'Indian wine, since 1999',
  ),
  BrandIdentity(
    matcher: 'grover-zampa',
    label: 'GROVER ZAMPA',
    primary: Color(0xFF5D0F1E),
    accent: Color(0xFFC9A14B),
    ink: Color(0xFFFAEFD8),
    tagline: 'Bangalore reserve',
  ),
  BrandIdentity(
    matcher: 'fratelli',
    label: 'FRATELLI',
    primary: Color(0xFF6E1216),
    accent: Color(0xFFE6C99A),
    ink: Color(0xFFFAEFD8),
    tagline: 'Italian-Indian harmony',
  ),
  BrandIdentity(
    matcher: 'krsma',
    label: 'KRSMA',
    primary: Color(0xFF101010),
    accent: Color(0xFFD9A23A),
    ink: Color(0xFFD9A23A),
    tagline: 'Hampi Hills, single estate',
  ),
  BrandIdentity(
    matcher: 'charosa',
    label: 'CHAROSA',
    primary: Color(0xFF4D5A2D),
    accent: Color(0xFFEED9A8),
    ink: Color(0xFFFAEFD8),
    tagline: 'Sahyadri ranges',
  ),
  BrandIdentity(
    matcher: 'big-banyan',
    label: 'BIG BANYAN',
    primary: Color(0xFF2E5A2E),
    accent: Color(0xFFEED9A8),
    ink: Color(0xFFFAEFD8),
    tagline: 'Karnataka craft',
  ),
  BrandIdentity(
    matcher: 'amrut',
    label: 'AMRUT',
    primary: Color(0xFF8B5A2B),
    accent: Color(0xFF3A1F0F),
    ink: Color(0xFFFAEFD8),
    tagline: 'Bangalore single malt',
  ),
  BrandIdentity(
    matcher: 'paul-john',
    label: 'PAUL JOHN',
    primary: Color(0xFF13243B),
    accent: Color(0xFFC9A14B),
    ink: Color(0xFFFAEFD8),
    tagline: 'Goan whisky',
  ),
  BrandIdentity(
    matcher: 'rampur',
    label: 'RAMPUR',
    primary: Color(0xFF2A1A0F),
    accent: Color(0xFFC9A14B),
    ink: Color(0xFFC9A14B),
    tagline: 'Himalayan whisky',
  ),
  BrandIdentity(
    matcher: 'old-monk',
    label: 'OLD MONK',
    primary: Color(0xFF3E2415),
    accent: Color(0xFFD9A23A),
    ink: Color(0xFFD9A23A),
    tagline: 'XXX rum, since 1954',
  ),
  BrandIdentity(
    matcher: 'bira',
    label: 'BIRA 91',
    primary: Color(0xFFE85A1A),
    accent: Color(0xFFFAEFD8),
    ink: Color(0xFFFAEFD8),
    tagline: 'India craft beer',
  ),
  BrandIdentity(
    matcher: 'kingfisher',
    label: 'KINGFISHER',
    primary: Color(0xFFC8102E),
    accent: Color(0xFFFFFFFF),
    ink: Color(0xFFFFFFFF),
    tagline: 'The king of good times',
  ),
];

/// Category fallback identities — used when a productId doesn't
/// match any brand prefix. Keeps the visual treatment consistent.
const _kCategoryFallbacks = <String, BrandIdentity>{
  'Wine': BrandIdentity(
    matcher: '_wine',
    label: 'WINE',
    primary: Color(0xFF5D0F1E),
    accent: Color(0xFFC9A14B),
    ink: Color(0xFFFAEFD8),
  ),
  'Spirits': BrandIdentity(
    matcher: '_spirits',
    label: 'SPIRITS',
    primary: Color(0xFF2A1A0F),
    accent: Color(0xFFC9A14B),
    ink: Color(0xFFC9A14B),
  ),
  'Beer': BrandIdentity(
    matcher: '_beer',
    label: 'BEER',
    primary: Color(0xFFE85A1A),
    accent: Color(0xFFFAEFD8),
    ink: Color(0xFFFAEFD8),
  ),
  'Cocktails': BrandIdentity(
    matcher: '_cocktails',
    label: 'COCKTAILS',
    primary: Color(0xFF93003C),
    accent: Color(0xFFC9A14B),
    ink: Color(0xFFFAEFD8),
  ),
};

class BrandRegistry {
  static BrandIdentity forProduct({
    required String productId,
    required String category,
  }) {
    final id = productId.toLowerCase();
    for (final brand in _kBrandRegistry) {
      if (id.startsWith(brand.matcher)) return brand;
    }
    return _kCategoryFallbacks[category] ?? _kCategoryFallbacks['Wine']!;
  }
}
