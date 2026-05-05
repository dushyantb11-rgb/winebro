/// Public aggregate of journal activity per product, written
/// nightly by CF-11. Read by the Bro Circle on Home.
class CommunitySignal {
  const CommunitySignal({
    required this.productId,
    required this.productName,
    required this.category,
    required this.region,
    required this.tastersThisWeek,
    required this.tastersPrevWeek,
    required this.lovedThisWeek,
    required this.climbingScore,
    required this.lovedRate,
    this.topPairing,
    this.topPairingShare = 0,
  });

  final String productId;
  final String productName;
  final String category;
  final String region;
  final int tastersThisWeek;
  final int tastersPrevWeek;
  final int lovedThisWeek;
  final double climbingScore;
  final double lovedRate;
  final String? topPairing;
  final double topPairingShare;

  bool get isClimbing => climbingScore >= 0.5;
  bool get isLoved => lovedRate >= 0.7 && tastersThisWeek >= 3;

  factory CommunitySignal.fromMap(Map<String, dynamic> map) =>
      CommunitySignal(
        productId: map['productId'] as String,
        productName: (map['productName'] as String?) ?? '',
        category: (map['category'] as String?) ?? '',
        region: (map['region'] as String?) ?? '',
        tastersThisWeek: (map['tastersThisWeek'] as num?)?.toInt() ?? 0,
        tastersPrevWeek: (map['tastersPrevWeek'] as num?)?.toInt() ?? 0,
        lovedThisWeek: (map['lovedThisWeek'] as num?)?.toInt() ?? 0,
        climbingScore: (map['climbingScore'] as num?)?.toDouble() ?? 0,
        lovedRate: (map['lovedRate'] as num?)?.toDouble() ?? 0,
        topPairing: map['topPairing'] as String?,
        topPairingShare:
            (map['topPairingShare'] as num?)?.toDouble() ?? 0,
      );
}
