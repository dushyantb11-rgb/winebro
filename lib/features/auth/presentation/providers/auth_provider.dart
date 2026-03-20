import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:winebro/core/services/firebase_providers.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore,
        super(const AuthLoading()) {
    _init();
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final _googleSignIn = GoogleSignIn();
  late final StreamSubscription<User?> _authSub;

  void _init() {
    _authSub = _auth.authStateChanges().listen((user) async {
      if (user == null) {
        state = const Unauthenticated();
        return;
      }

      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          state = NeedsProfile(userId: user.uid, email: user.email);
          return;
        }

        final data = doc.data()!;
        final hasQuiz = data['hasCompletedQuiz'] as bool? ?? false;

        if (!hasQuiz) {
          state = NeedsOnboarding(
            userId: user.uid,
            displayName: data['displayName'] as String? ?? '',
          );
          return;
        }

        state = Authenticated(
          user: WineBroUser.fromMap({...data, 'id': user.uid}),
        );
      } on Exception catch (e) {
        state = AuthError(message: 'Failed to load profile: $e');
      }
    });
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = const AuthLoading();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          state = AuthError(message: _mapFirebaseError(e.code, e.message));
        },
        codeSent: (verificationId, _) {
          state = OtpSent(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
          );
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on Exception catch (e) {
      state = AuthError(message: 'Failed to send OTP: $e');
    }
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    state = const AuthLoading();
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      state = AuthError(message: _mapFirebaseError(e.code));
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = const Unauthenticated();
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on Exception catch (e) {
      state = AuthError(message: 'Google sign-in failed: $e');
    }
  }

  Future<void> saveProfile({
    required String displayName,
    required bool isAgeVerified,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'hasCompletedQuiz': false,
        'isAgeVerified': isAgeVerified,
        'createdAt': FieldValue.serverTimestamp(),
      });

      state = NeedsOnboarding(
        userId: user.uid,
        displayName: displayName,
      );
    } on Exception catch (e) {
      state = AuthError(message: 'Failed to save profile: $e');
    }
  }

  Future<void> completeOnboarding() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'hasCompletedQuiz': true,
      });

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        state = Authenticated(
          user: WineBroUser.fromMap({...doc.data()!, 'id': user.uid}),
        );
      }
    } on Exception catch (e) {
      state = AuthError(message: 'Failed to complete onboarding: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } on Exception catch (_) {}
    state = const Unauthenticated();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  String _mapFirebaseError(String code, [String? details]) => switch (code) {
    'too-many-requests' => 'Too many attempts. Please wait a moment and try again.',
    'invalid-verification-code' => 'Invalid OTP. Please check and try again.',
    'session-expired' => 'OTP has expired. Please request a new one.',
    'account-exists-with-different-credential' => 'An account already exists with this email. Try a different sign-in method.',
    'invalid-phone-number' => 'Invalid phone number. Please check and try again.',
    'missing-phone-number' => 'Please enter a phone number.',
    'quota-exceeded' => 'SMS quota exceeded. Please try again later.',
    'app-not-authorized' => 'This app is not authorized for Firebase Phone Auth. Check SHA-1 configuration.',
    'network-request-failed' => 'Network error. Please check your connection.',
    _ => details ?? 'Something went wrong ($code). Please try again.',
  };
}

