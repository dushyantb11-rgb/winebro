/// WineBro notification types. Each type defines what the FCM
/// `data` payload looks like and where tapping should deep-link.
///
/// Schema (all FCM messages MUST include this in the data map):
///   data: {
///     "type": "<one of WineBroNotificationType.code>",
///     ...type-specific fields below
///   }
///
/// The Cloud Functions in Sprint 2 emit these. The on-device handler
/// in [NotificationHandler] resolves them to the correct deep-link.
enum WineBroNotificationType {
  /// Daily Bro Tip push (8 PM IST). Deep-links to Home.
  ///   data.tipId       — id of the Bro Tip rendered
  broTip(code: 'broTip', deepLink: '/'),

  /// Sent at 9 PM if the user's streak is about to lapse.
  /// Deep-links to Profile so they see what's at stake.
  ///   data.streakDays  — current streak count (string)
  streakLoss(code: 'streakLoss', deepLink: '/profile'),

  /// 7 AM morning push surfacing today's curated bottle. Deep-links
  /// to Home so the hero card reloads with the Tonight's Pour.
  ///   data.productId
  tonightsPour(code: 'tonightsPour', deepLink: '/'),

  /// Sunday 11 AM weekly nudge for buy-again items. Deep-links to
  /// the Restock surface (initially Home; v1.1 dedicated screen).
  ///   data.productId
  restock(code: 'restock', deepLink: '/'),

  /// 24 hours after a Pair save/buy: "Did Bro get it right?"
  /// Tapping records `feedback_pairing_correct` event and deep-links
  /// to the original product detail.
  ///   data.productId
  ///   data.dishId      (nullable)
  ///   data.matchPercent
  pairingFeedback(code: 'pairingFeedback', deepLink: '/'),

  /// Generic catch-all. Deep-links to Home.
  unknown(code: 'unknown', deepLink: '/');

  const WineBroNotificationType({required this.code, required this.deepLink});
  final String code;
  final String deepLink;

  static WineBroNotificationType fromCode(String? code) {
    if (code == null) return WineBroNotificationType.unknown;
    return WineBroNotificationType.values.firstWhere(
      (t) => t.code == code,
      orElse: () => WineBroNotificationType.unknown,
    );
  }
}

/// Parsed notification payload — what we hand to deep-link handlers
/// after extracting [WineBroNotificationType] and any type-specific
/// fields from the FCM data map.
class WineBroNotification {
  const WineBroNotification({
    required this.type,
    required this.data,
  });

  final WineBroNotificationType type;
  final Map<String, String> data;

  factory WineBroNotification.fromData(Map<String, dynamic> raw) {
    final stringified = <String, String>{
      for (final entry in raw.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
    return WineBroNotification(
      type: WineBroNotificationType.fromCode(stringified['type']),
      data: stringified,
    );
  }
}
