import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/friends/domain/friend.dart';

/// Phone-number-keyed friend graph.
///
/// Storage layout:
///   phone_index/{hmac(pepper, e164)} → { uid }   (server-only, CF-13)
///   users/{me}/friends/{theirUid}  = Friend
///
/// Privacy: contact phone numbers leave the device only as
/// SHA-256 hashes of E.164 — server can map a hash back to a uid
/// only if that uid already wrote their own hash to phone_index.
/// We never store the user's contacts list anywhere.
class FriendRepository {
  FriendRepository(this._firestore, this._auth, [FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  /// Asks the server to index this account's verified phone number
  /// (peppered HMAC, never a plain hash) so contacts can find it.
  /// Best-effort; idempotent.
  Future<void> ensureSelfIndexed() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) return;
    try {
      await _functions.httpsCallable('registerPhoneIndex').call<Map<String, dynamic>>();
    } on FirebaseFunctionsException catch (e) {
      debugPrint('registerPhoneIndex: ${e.code} ${e.message}');
    }
  }

  /// Read device contacts (caller owns the permission prompt), send the
  /// numbers to the server, which matches them against the peppered
  /// index and returns only users who allow discovery. Does NOT
  /// auto-follow — the user reviews + opts in.
  Future<List<DiscoveredFriend>> discoverFromContacts() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) return const [];

    final me = _auth.currentUser?.uid;
    if (me == null) return const [];

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    // number → contact name (last-wins; same number, same person).
    final phoneToName = <String, String>{};
    for (final c in contacts) {
      for (final p in c.phones) {
        final raw = p.number.replaceAll(RegExp(r'[^\d+]'), '');
        if (raw.length < 8) continue;
        phoneToName[raw] = c.displayName;
      }
    }
    if (phoneToName.isEmpty) return const [];

    final results = <DiscoveredFriend>[];
    final phones = phoneToName.keys.toList();
    const chunk = 500; // server limit per call
    for (var i = 0; i < phones.length; i += chunk) {
      final part = phones.sublist(i, i + chunk > phones.length ? phones.length : i + chunk);
      final res = await _functions
          .httpsCallable('lookupContacts')
          .call<Map<String, dynamic>>({'phones': part});
      final matches = (res.data['matches'] as List?) ?? const [];
      for (final m in matches) {
        if (m is! Map) continue;
        final uid = m['uid'] as String?;
        if (uid == null || uid == me) continue;
        // The contact-list name is what the discoverer already knows
        // them by, which is the honest label to show.
        final name = phoneToName[m['phone'] as String? ?? ''] ?? '';
        results.add(DiscoveredFriend(uid: uid, contactName: name, displayName: name));
      }
    }
    return results;
  }

  /// Follow another user. Idempotent — re-tap is a no-op.
  Future<void> follow({
    required String targetUid,
    required String displayName,
  }) async {
    final me = _auth.currentUser?.uid;
    if (me == null || me == targetUid) return;
    final friend = Friend(
      uid: targetUid,
      displayName: displayName,
      followedAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(me)
        .collection('friends')
        .doc(targetUid)
        .set(friend.toMap());
  }

  Future<void> unfollow(String targetUid) async {
    final me = _auth.currentUser?.uid;
    if (me == null) return;
    await _firestore
        .collection('users')
        .doc(me)
        .collection('friends')
        .doc(targetUid)
        .delete();
  }

  Stream<List<Friend>> friendsStream() {
    final me = _auth.currentUser?.uid;
    if (me == null) return Stream.value(const []);
    return _firestore
        .collection('users')
        .doc(me)
        .collection('friends')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => Friend.fromMap(d.data())).toList());
  }

  Stream<Set<String>> friendUidsStream() {
    return friendsStream().map((list) => list.map((f) => f.uid).toSet());
  }

  /// Set the user's profile visibility (public / friends / private).
  Future<void> setVisibility(ProfileVisibility v) async {
    final me = _auth.currentUser?.uid;
    if (me == null) return;
    await _firestore
        .collection('users')
        .doc(me)
        .set({'visibility': v.code}, SetOptions(merge: true));
  }

  Stream<ProfileVisibility> visibilityStream() {
    final me = _auth.currentUser?.uid;
    if (me == null) return Stream.value(ProfileVisibility.friendsOnly);
    return _firestore
        .collection('users')
        .doc(me)
        .snapshots()
        .map((d) => ProfileVisibility.fromCode(d.data()?['visibility'] as String?));
  }
}

final friendRepositoryProvider = Provider<FriendRepository>(
  (_) => FriendRepository(FirebaseFirestore.instance, FirebaseAuth.instance),
);

final friendsStreamProvider = StreamProvider<List<Friend>>(
  (ref) => ref.watch(friendRepositoryProvider).friendsStream(),
);

final friendUidsStreamProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(friendRepositoryProvider).friendUidsStream(),
);

final profileVisibilityProvider = StreamProvider<ProfileVisibility>(
  (ref) => ref.watch(friendRepositoryProvider).visibilityStream(),
);
