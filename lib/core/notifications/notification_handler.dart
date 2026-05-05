import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/notifications/notification_types.dart';

/// Background message handler.
///
/// MUST be a top-level (or static) function — Flutter spawns a separate
/// isolate for background pushes and can only reach top-level entry points.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
    'Background message received: type=${message.data['type']} '
    'title=${message.notification?.title}',
    name: 'wb.fcm',
  );
  // Background processing is a TODO for the Sprint 2 server-side feedback
  // loop (e.g., persist a "feedback ask" record so it shows on next open
  // even if the user never taps the push). For now we just log.
}

/// Single owner of FCM lifecycle for WineBro.
///
/// Responsibilities:
///   1. Permission prompt (on first launch + via Settings)
///   2. Topic subscriptions per [WineBroNotificationType]
///   3. Foreground / background / terminated handlers wired to deep-links
///   4. Token registration (write to users/{uid}/fcm_token)
///
/// Init is called once from main.dart after Firebase.initializeApp().
class NotificationHandler {
  NotificationHandler._();
  static final instance = NotificationHandler._();

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  GoRouter? _router;

  /// Bind a router so notification taps can deep-link. Call after
  /// router creation (typically in WineBroApp.build via a one-shot ref).
  void bindRouter(GoRouter router) {
    _router = router;
  }

  /// Bootstrap. Call from main.dart AFTER Firebase.initializeApp().
  /// Idempotent: safe to call once per process.
  Future<void> initialize() async {
    if (kIsWeb) return; // FCM web flow not in scope for v1.0

    final messaging = FirebaseMessaging.instance;

    // Background handler must be registered before runApp().
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages — show in-app banner / toast (TODO Sprint 2).
    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForeground);

    // Tap from background-but-not-killed.
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

    // Tap from terminated (cold-start). Returns the message that opened
    // the app, if any.
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _onOpened(initial);
    }

    developer.log('NotificationHandler initialized', name: 'wb.fcm');
  }

  /// Request notification permissions. Called from auth flow after
  /// sign-in completes, OR from Settings if the user toggles them on.
  Future<bool> requestPermissions() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    developer.log(
      'Permission request: ${settings.authorizationStatus}',
      name: 'wb.fcm',
    );
    return granted;
  }

  /// Subscribe the user to all relevant topics. Topics correspond 1:1
  /// to [WineBroNotificationType]. Cloud Functions in Sprint 2 publish
  /// to these topics.
  Future<void> subscribeAll() async {
    final messaging = FirebaseMessaging.instance;
    for (final type in WineBroNotificationType.values) {
      if (type == WineBroNotificationType.unknown) continue;
      await messaging.subscribeToTopic(type.code);
    }
    developer.log('Subscribed to all notification topics', name: 'wb.fcm');
  }

  Future<void> unsubscribeAll() async {
    final messaging = FirebaseMessaging.instance;
    for (final type in WineBroNotificationType.values) {
      if (type == WineBroNotificationType.unknown) continue;
      await messaging.unsubscribeFromTopic(type.code);
    }
  }

  /// Read the FCM token. Persist this to users/{uid}/fcm_token in
  /// Firestore on sign-in so server-side targeting can address it.
  Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  /// One-shot post-authentication setup. Called from the auth listener
  /// in WineBroApp the moment a user becomes [Authenticated]. Idempotent.
  ///
  /// Steps:
  ///   1. Request notification permissions (no-op if already granted)
  ///   2. Subscribe to all topic broadcasts (broTip, tonightsPour, ...)
  ///   3. Persist FCM token to users/{uid}/fcm_token/primary so CF-07
  ///      streakLossWarning can target this user
  ///   4. Listen for token refresh events and update Firestore
  Future<void> registerForUser(String uid) async {
    if (kIsWeb) return;
    final granted = await requestPermissions();
    if (!granted) {
      developer.log(
        'Notifications declined; skipping topic subscribe + token write',
        name: 'wb.fcm',
      );
      return;
    }

    await subscribeAll();

    // Token + refresh subscription
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token != null) {
      await _writeToken(uid, token);
    }
    messaging.onTokenRefresh.listen((newToken) async {
      await _writeToken(uid, newToken);
    });
  }

  Future<void> _writeToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fcm_token')
          .doc('primary')
          .set({
        'token': token,
        'updatedAt': DateTime.now().toIso8601String(),
        'platform': defaultTargetPlatform.name,
      });
    } catch (e) {
      developer.log('FCM token write failed: $e', name: 'wb.fcm');
    }
  }

  // ====================================================================
  // Internals
  // ====================================================================

  void _onForeground(RemoteMessage message) {
    final n = WineBroNotification.fromData(message.data);
    developer.log('Foreground push: ${n.type.code}', name: 'wb.fcm');
    // TODO Sprint 2: surface as in-app SnackBar / banner via a global
    // ScaffoldMessenger key. For now silent capture in logs.
  }

  void _onOpened(RemoteMessage message) {
    final n = WineBroNotification.fromData(message.data);
    developer.log('Opened from push: ${n.type.code}', name: 'wb.fcm');
    final router = _router;
    if (router == null) {
      developer.log(
        'Router not bound yet; deep-link skipped',
        name: 'wb.fcm',
      );
      return;
    }
    router.go(n.type.deepLink);
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
  }
}
