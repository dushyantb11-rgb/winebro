import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/wishlist/domain/wishlist_entry.dart';

/// Stream of the active user's wishlist, newest first.
final wishlistProvider = StreamProvider<List<WishlistEntry>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('wishlist')
      .orderBy('savedAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => WishlistEntry.fromMap(d.data())).toList());
});

/// `productId -> isInWishlist` lookup derived from [wishlistProvider].
/// Used by Buy/Save/Remind buttons to render Save vs Saved state.
final wishlistContainsProvider = Provider.family<bool, String>((ref, productId) {
  final list = ref.watch(wishlistProvider).value ?? const [];
  return list.any((e) => e.productId == productId);
});

class WishlistRepository {
  WishlistRepository(this._firestore, this._uid);
  final FirebaseFirestore _firestore;
  final String _uid;

  static WishlistRepository? forCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return WishlistRepository(FirebaseFirestore.instance, uid);
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(_uid).collection('wishlist');

  Future<void> save(Product product) {
    final entry = WishlistEntry(
      productId: product.id,
      productName: product.name,
      category: product.category.group,
      region: product.region,
      savedAt: DateTime.now(),
      priceInr: product.price,
    );
    return _col.doc(product.id).set(entry.toMap());
  }

  Future<void> remove(String productId) => _col.doc(productId).delete();
}
