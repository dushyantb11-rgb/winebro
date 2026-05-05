/// User's post-tasting verdict on a Bro pairing recommendation.
/// Collected 24h after the journal entry via CF-09 push.
///
/// This is the D6 "Pairing Success Rate" data asset — every Yes/No
/// tunes the next user's pick in the engine v1.1 (S2.3).
enum PairingResponse {
  yes(code: 'yes'),
  maybe(code: 'maybe'),
  no(code: 'no');

  const PairingResponse({required this.code});
  final String code;

  static PairingResponse? fromCode(String? c) {
    if (c == null) return null;
    return PairingResponse.values.firstWhere(
      (r) => r.code == c,
      orElse: () => PairingResponse.maybe,
    );
  }
}

class PairingFeedback {
  const PairingFeedback({
    required this.id,
    required this.userId,
    required this.entryId,
    required this.productId,
    required this.productName,
    required this.foodPaired,
    required this.response,
    required this.respondedAt,
  });

  final String id;
  final String userId;
  final String entryId;
  final String productId;
  final String productName;
  final String foodPaired;
  final PairingResponse response;
  final DateTime respondedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'entryId': entryId,
        'productId': productId,
        'productName': productName,
        'foodPaired': foodPaired,
        'response': response.code,
        'respondedAt': respondedAt.toIso8601String(),
      };
}
