import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/config/app_config.dart';

/// Actions that earn XP. The amounts come from `config/gamification`.
enum GamificationAction {
  scan,
  journalEntry,
  pairing;

  /// XP for this action, from `config/gamification`.
  int get xp => AppConfig.current.gamification.xpFor(name);
}

/// Records what the user did. The app never writes XP, streak, level or
/// badges itself: it appends an immutable event to
/// `users/{uid}/events/{id}` and the server (CF-02) turns events into
/// `users/{uid}/gamification/state`, which Profile streams.
///
/// Wired into:
///   - Scanner match success
///   - Quick-log save (always; +pairing if foodPaired set)
///   - BroCard detailed save
class GamificationService {
  GamificationService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> recordAction(
    GamificationAction action, {
    String? category,
    bool withFoodPairing = false,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('events').add({
      'type': action.name,
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
      if (withFoodPairing) 'withFoodPairing': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

final gamificationServiceProvider = Provider<GamificationService>(
  (ref) => GamificationService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  ),
);
