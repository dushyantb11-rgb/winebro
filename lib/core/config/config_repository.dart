import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/config/app_config.dart';
import 'package:winebro/core/preview/drafts_preview.dart';

/// Streams Firestore `config/*` as an [AppConfig], falling back to the
/// bundled defaults per document, and keeps [AppConfig.current] in step.
class ConfigRepository {
  ConfigRepository(this._db);

  final FirebaseFirestore _db;

  Stream<AppConfig> watch({
    Map<String, Map<String, dynamic>> overrides = const {},
  }) =>
      _db
          .collection('config')
          .snapshots()
          .map((snap) {
        final json = <String, dynamic>{
          for (final d in snap.docs) d.id: d.data(),
          // Console preview / admin drafts layered over the live documents.
          ...overrides,
        };
        final config = AppConfig.fromJson(
          json,
          fallback: AppConfig.defaults,
          onError: (doc, error, stack) {
            if (!kIsWeb) {
              FirebaseCrashlytics.instance
                  .recordError(error, stack, reason: 'config/$doc failed to parse');
            }
          },
        );
        AppConfig.current = config;
        return config;
      }).handleError((Object error, StackTrace stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance
              .recordError(error, stack, reason: 'config stream');
        }
      });
}

final configRepositoryProvider = Provider<ConfigRepository>(
  (_) => ConfigRepository(FirebaseFirestore.instance),
);

/// The live config. Starts with the bundled defaults, then follows
/// Firestore (cache first, then server).
final appConfigProvider = StreamProvider<AppConfig>(
  (ref) => ref.watch(configRepositoryProvider).watch(
        overrides: ref.watch(effectiveOverridesProvider).config,
      ),
);
