/// User's saved-for-later product. Materialised at
/// `users/{uid}/wishlist/{productId}`.
class WishlistEntry {
  const WishlistEntry({
    required this.productId,
    required this.productName,
    required this.category,
    required this.region,
    required this.savedAt,
    this.priceInr,
  });

  final String productId;
  final String productName;
  final String category;
  final String region;
  final DateTime savedAt;
  final double? priceInr;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'category': category,
        'region': region,
        'savedAt': savedAt.toIso8601String(),
        if (priceInr != null) 'priceInr': priceInr,
      };

  factory WishlistEntry.fromMap(Map<String, dynamic> map) => WishlistEntry(
        productId: map['productId'] as String,
        productName: map['productName'] as String,
        category: map['category'] as String? ?? '',
        region: map['region'] as String? ?? '',
        savedAt: DateTime.parse(map['savedAt'] as String),
        priceInr: (map['priceInr'] as num?)?.toDouble(),
      );
}
