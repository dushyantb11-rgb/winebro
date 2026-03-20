import 'package:cloud_firestore/cloud_firestore.dart';

sealed class AuthState {
  const AuthState();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class OtpSent extends AuthState {
  const OtpSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;
}

final class NeedsProfile extends AuthState {
  const NeedsProfile({required this.userId, this.email});

  final String userId;
  final String? email;
}

final class NeedsOnboarding extends AuthState {
  const NeedsOnboarding({required this.userId, required this.displayName});

  final String userId;
  final String displayName;
}

final class Authenticated extends AuthState {
  const Authenticated({required this.user});

  final WineBroUser user;
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;
}

final class WineBroUser {
  const WineBroUser({
    required this.id,
    required this.displayName,
    this.email,
    this.phoneNumber,
    this.hasCompletedQuiz = false,
    this.isAgeVerified = false,
    this.createdAt,
  });

  final String id;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final bool hasCompletedQuiz;
  final bool isAgeVerified;
  final DateTime? createdAt;

  WineBroUser copyWith({
    String? id,
    String? displayName,
    String? email,
    String? phoneNumber,
    bool? hasCompletedQuiz,
    bool? isAgeVerified,
    DateTime? createdAt,
  }) {
    return WineBroUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hasCompletedQuiz: hasCompletedQuiz ?? this.hasCompletedQuiz,
      isAgeVerified: isAgeVerified ?? this.isAgeVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'displayName': displayName,
    if (email != null) 'email': email,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    'hasCompletedQuiz': hasCompletedQuiz,
    'isAgeVerified': isAgeVerified,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  factory WineBroUser.fromMap(Map<String, dynamic> map) {

    DateTime? createdAt;
    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    } else if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    }

    return WineBroUser(
      id: map['id'] as String,
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      hasCompletedQuiz: map['hasCompletedQuiz'] as bool? ?? false,
      isAgeVerified: map['isAgeVerified'] as bool? ?? false,
      createdAt: createdAt,
    );
  }
}

