import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/friends/domain/friend.dart';

/// Phone-number-keyed friend graph.
///
/// Storage layout:
///   phone_index/{sha256(e164)} → { uid }
///   users/{uid}.phoneHash      = sha256 of own phone
///   users/{me}/friends/{theirUid}  = Friend
///
/// Privacy: contact phone numbers leave the device only as
/// SHA-256 hashes of E.164 — server can map a hash back to a uid
/// only if that uid already wrote their own hash to phone_index.
/// We never store the user's contacts list anywhere.
class FriendRepository {
  FriendRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Hash a normalized E.164 phone number.
  static String hashPhone(String e164) {
    final normalized = e164.replaceAll(RegExp(r'[^\d+]'), '');
    return sha256.convert(utf8.encode(normalized)).toString();
  }

  /// Best-effort phone-index write on every login. The user's hash
  /// must exist in phone_index for friends-of-friends to discover
  /// them. Idempotent — uses set+merge.
  Future<void> ensureSelfIndexed() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final phone = user.phoneNumber;
    if (phone == null || phone.isEmpty) return;
    final hash = hashPhone(phone);
    await _firestore.collection('phone_index').doc(hash).set({
      'uid': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Mirror onto own user doc so we can detect mismatches later.
    await _firestore.collection('users').doc(user.uid).set(
      {'phoneHash': hash},
      SetOptions(merge: true),
    );
  }

  /// Read device contacts (caller owns the permission prompt),
  /// hash each phone, batch-lookup phone_index, return matched
  /// users. Does NOT auto-follow — the user reviews + opts in.
  Future<List<DiscoveredFriend>> discoverFromContacts() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) return const [];

    final me = _auth.currentUser?.uid;
    if (me == null) return const [];
    final myPhone = _auth.currentUser?.phoneNumber;
    final myHash = myPhone != null ? hashPhone(myPhone) : null;

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    // Build hash → contact name map (last-wins is fine — same hash
    // means same number, so the name they share with their contact
    // entry is whichever was processed last).
    final hashToName = <String, String>{};
    for (final c in contacts) {
      for (final p in c.phones) {
        final raw = p.number;
        if (raw.trim().isEmpty) continue;
        final hash = hashPhone(raw);
        if (hash == myHash) continue;
        hashToName[hash] = c.displayName;
      }
    }
    if (hashToName.isEmpty) return const [];

    // Firestore whereIn caps at 30 — chunk.
    const chunkSize = 30;
    final hashes = hashToName.keys.toList();
    final results = <DiscoveredFriend>[];

    for (var i = 0; i < hashes.length; i += chunkSize) {
      final chunk = hashes.sublist(
        i,
        i + chunkSize > hashes.length ? hashes.length : i + chunkSize,
      );
      final snap = await _firestore
          .collection('phone_index')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final uid = doc.data()['uid'] as String?;
        if (uid == null || uid == me) continue;
        final contactName = hashToName[doc.id] ?? '';
        // We deliberately don't read users/{uid} here — the user's
        // user doc is owner-only readable. The contact-list name is
        // what the discoverer already knows them by, which is the
        // honest label to show. After following, the per-user friends
        // doc denormalizes whatever name we render.
        results.add(DiscoveredFriend(
          uid: uid,
          contactName: contactName,
          displayName: contactName,
        ));
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
