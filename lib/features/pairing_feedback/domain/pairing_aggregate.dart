/// Public aggregate of `pairing_feedback` rows for a single
/// (productId, dishKey) pair. Read from `pairing_aggregates/{id}`
/// where id = `${productId}__${dishKey}`.
///
/// This is what S2.3 engine v1.1 consumes — every Yes/Maybe/No tally
/// the community has logged is rolled up here and used to nudge the
/// pairing recommendation up or down.
class PairingAggregate {
  const PairingAggregate({
    required this.productId,
    required this.dishKey,
    required this.yes,
    required this.maybe,
    required this.no,
  });

  final String productId;
  final String dishKey;
  final int yes;
  final int maybe;
  final int no;

  int get total => yes + maybe + no;

  /// Yes-rate biased toward neutral (0.5) with low sample size, via
  /// Bayesian shrinkage with prior strength `k`. Avoids letting a
  /// single Yes tilt the score to 100% confidence.
  ///
  /// score = (yes + 0.5 * maybe + k * 0.5) / (total + k)
  ///
  /// Maybe is counted as half a Yes — the user couldn't fully commit
  /// either way, so it pulls slightly toward neutral on its own merit.
  double shrunkYesRate({double prior = 10}) {
    final positive = yes + 0.5 * maybe;
    return (positive + prior * 0.5) / (total + prior);
  }

  /// Bayesian-shrunk yes-rate centred on 0 (so "no community signal"
  /// returns 0 instead of 0.5). Range approximately [-0.5, 0.5];
  /// with low sample size, magnitude is small even if all Yes.
  double signedShrunkBias({double prior = 10}) =>
      shrunkYesRate(prior: prior) - 0.5;

  factory PairingAggregate.fromMap(Map<String, dynamic> map) =>
      PairingAggregate(
        productId: map['productId'] as String,
        dishKey: map['dishKey'] as String,
        yes: (map['yes'] as int?) ?? 0,
        maybe: (map['maybe'] as int?) ?? 0,
        no: (map['no'] as int?) ?? 0,
      );

  /// Build the document id used in `pairing_aggregates`.
  /// Mirrors the normalization the writer (PairingFeedbackSheet) uses.
  static String docIdFor({required String productId, required String dishKey}) =>
      '${productId}__$dishKey';

  static String normalizeDishKey(String dish) {
    return dish
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
