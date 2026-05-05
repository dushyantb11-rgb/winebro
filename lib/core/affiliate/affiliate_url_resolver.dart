import 'package:winebro/features/pairing/domain/product.dart';

/// Resolves a partner-store URL for a [Product]. Until partner BD is
/// signed (Living Liquidz / BlackBook / Hipbar / Tonique), this returns
/// a search-link to a partner-agnostic landing page with affiliate
/// tracking parameters appended.
///
/// Once a partner contract lands, swap [_basePartnerUrl] to the
/// partner's PDP search endpoint and add the partner-specific tracking
/// param (e.g., `aff=winebro&utm_campaign=app_pair`).
class AffiliateUrlResolver {
  AffiliateUrlResolver._();

  /// Default partner-agnostic base. Replace with signed partner's
  /// search endpoint when ready.
  static const _basePartnerUrl = 'https://www.living-liquidz.com/search';

  /// Build the URL the user opens when they tap "Buy ₹X".
  ///
  /// Includes:
  ///   - product name as a search query
  ///   - winebro tracking ref (so partner can attribute the install)
  ///   - source surface (pair / tonightsPour / detail) for analytics
  static Uri buildBuyUrl({
    required Product product,
    required AffiliateSource source,
  }) {
    return Uri.parse(_basePartnerUrl).replace(queryParameters: {
      'q': product.name,
      'ref': 'winebro',
      'src': source.code,
      'pid': product.id,
    });
  }
}

/// Where the buy click originated. Tracked as analytics dimension once
/// S1.1 instrumentation is wired.
enum AffiliateSource {
  pair('pair'),
  tonightsPour('tonightsPour'),
  detail('detail'),
  brocard('brocard'),
  wishlist('wishlist');

  const AffiliateSource(this.code);
  final String code;
}
