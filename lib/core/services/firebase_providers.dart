import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/preview/preview_overrides.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';

final firebaseAuthProvider = Provider((_) => FirebaseAuth.instance);
final firestoreProvider = Provider((_) => FirebaseFirestore.instance);

final currentUidProvider = Provider<String?>((ref) {
  // Console preview "new user" state: no personal history at all.
  if (kPreviewMode && ref.watch(previewUserStateProvider) == 'new') return null;
  final auth = ref.watch(authStateProvider);
  return switch (auth) {
    Authenticated(:final user) => user.id,
    NeedsProfile(:final userId) => userId,
    NeedsOnboarding(:final userId) => userId,
    _ => null,
  };
});

final userDocRefProvider = Provider<DocumentReference?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  return ref.read(firestoreProvider).collection('users').doc(uid);
});

