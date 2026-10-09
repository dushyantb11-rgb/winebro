import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/app.dart';
import 'package:winebro/core/notifications/notification_handler.dart';
import 'package:winebro/core/preview/preview_app.dart';
import 'package:winebro/core/preview/preview_overrides.dart';
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
      if (!kPreviewMode) await NotificationHandler.instance.initialize();

      if (!kIsWeb) {
        FlutterError.onError = (details) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } else {
        // Web (console preview): Crashlytics is unavailable; keep errors
        // visible in the browser console instead of swallowing them.
        FlutterError.onError = (details) {
          debugPrint('FlutterError: ${details.exceptionAsString()}\n${details.stack}');
        };
        PlatformDispatcher.instance.onError = (error, stack) {
          debugPrint('Uncaught: $error\n$stack');
          return true;
        };
      }

      // The console's mobile preview is the same app, rendered in a browser
      // with draft data layered on top; see core/preview/preview_app.dart.
      runApp(ProviderScope(
        child: kPreviewMode ? const PreviewApp() : const WineBroApp(),
      ));
    },
    (error, stack) {
      if (kIsWeb) {
        debugPrint('Uncaught (zone): $error\n$stack');
      } else if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
    },
  );
}

