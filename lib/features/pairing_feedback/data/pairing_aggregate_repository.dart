import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/pairing_feedback/domain/pairing_aggregate.dart';

/// Reads `pairing_aggregates` for a set of (productId, dishKey)
/// pairs. Used by S2.3 engine v1.1 to fold community feedback into
/// the ranking.
class PairingAggregateRepository {
  PairingAggregateRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Batch fetch aggregates for `productIds` × `dishKey`. Returns
  /// a map keyed by productId (since dishKey is fixed per call).
  /// Missing aggregates omit the key — callers should treat absence
  /// as "no community signal yet" (zero bias).
  Future<Map<String, PairingAggregate>> aggregatesForDish({
    required List<String> productIds,
    required String dishKey,
  }) async {
    if (productIds.isEmpty) return const {};

    // Firestore `whereIn` caps at 30. Chunk the request — most pair
    // queries are 10 products, so usually one batch is enough.
    const chunkSize = 30;
    final result = <String, PairingAggregate>{};

    for (var i = 0; i < productIds.length; i += chunkSize) {
      final chunk = productIds.sublist(
        i,
        i + chunkSize > productIds.length ? productIds.length : i + chunkSize,
      );
      final ids = chunk
          .map((pid) => PairingAggregate.docIdFor(
                productId: pid,
                dishKey: dishKey,
              ))
          .toList();

      final snap = await _firestore
          .collection('pairing_aggregates')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      for (final doc in snap.docs) {
        final agg = PairingAggregate.fromMap(doc.data());
        result[agg.productId] = agg;
      }
    }

    return result;
  }
}

final pairingAggregateRepositoryProvider =
    Provider<PairingAggregateRepository>(
  (_) => PairingAggregateRepository(FirebaseFirestore.instance),
);
