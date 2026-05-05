/// Privacy mode for a user's profile + journal visibility.
/// Default for new users is `friendsOnly`.
enum ProfileVisibility {
  public(code: 'public'),
  friendsOnly(code: 'friends'),
  private(code: 'private');

  const ProfileVisibility({required this.code});
  final String code;

  static ProfileVisibility fromCode(String? c) {
    if (c == null) return ProfileVisibility.friendsOnly;
    return ProfileVisibility.values.firstWhere(
      (v) => v.code == c,
      orElse: () => ProfileVisibility.friendsOnly,
    );
  }
}

/// One row in `users/{me}/friends/{friendUid}`. Lightweight — the
/// canonical user data lives at `users/{friendUid}` and is read on
/// demand. We denormalize displayName here so the friends list can
/// render without an extra fan-out read.
class Friend {
  const Friend({
    required this.uid,
    required this.displayName,
    required this.followedAt,
  });

  final String uid;
  final String displayName;
  final DateTime followedAt;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'followedAt': followedAt.toIso8601String(),
      };

  factory Friend.fromMap(Map<String, dynamic> map) => Friend(
        uid: map['uid'] as String,
        displayName: map['displayName'] as String? ?? '',
        followedAt: DateTime.parse(map['followedAt'] as String),
      );
}

/// Result of a contact discovery scan — a person whose phone is in
/// the user's address book AND who has a WineBro account.
class DiscoveredFriend {
  const DiscoveredFriend({
    required this.uid,
    required this.contactName,
    required this.displayName,
  });

  final String uid;
  final String contactName;
  final String displayName;
}
