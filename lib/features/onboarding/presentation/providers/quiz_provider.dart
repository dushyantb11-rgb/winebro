import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/profile/domain/gamification.dart';

final quizProfileProvider =
    StateNotifierProvider<QuizProfileNotifier, AsyncValue<PalateProfile?>>(
  (ref) => QuizProfileNotifier(),
);

class QuizProfileNotifier extends StateNotifier<AsyncValue<PalateProfile?>> {
  QuizProfileNotifier() : super(const AsyncData(null));

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveProfile(PalateProfile profile) async {
    state = const AsyncLoading();
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');

      await _firestore.collection('users').doc(uid).update({
        'palateProfile': profile.toMap(),
      });

      await _firestore.collection('users').doc(uid).collection('gamification').doc('state').set(
        GamificationState.initial().toMap(),
      );

      state = AsyncData(profile);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

