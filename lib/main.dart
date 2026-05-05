import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/app.dart';
import 'package:winebro/core/notifications/notification_handler.dart';
import 'package:winebro/firebase_options.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // FCM bootstrap — registers background handler + foreground/opened
      // listeners. Topic subscriptions + permission prompts happen later
      // via NotificationHandler.instance.requestPermissions() / subscribeAll()
      // (called from the auth flow after sign-in).
      await NotificationHandler.instance.initialize();

      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      runApp(const ProviderScope(child: WineBroApp()));
    },
    (error, stack) {
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
    },
  );
}

