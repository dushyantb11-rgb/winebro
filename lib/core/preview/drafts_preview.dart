import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winebro/core/preview/preview_overrides.dart';
import 'package:winebro/core/services/firebase_providers.dart';

/// On-phone preview of console drafts for admins.
///
/// An admin (users/{uid}.isAdmin, set from the console allow-list) can
/// switch on "Preview console drafts" in Settings. The app then layers
/// drafts_products / drafts_dishes / drafts_config over the live data on
/// this phone only. The switch is remembered on the device.
const _kPrefKey = 'previewDrafts';

/// True when the signed-in user is on the console allow-list.
final isAdminProvider = StreamProvider<bool>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(false);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((d) => d.data()?['isAdmin'] == true);
});

class DraftsPreviewNotifier extends StateNotifier<bool> {
  DraftsPreviewNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kPrefKey) ?? false;
  }

  Future<void> set(bool on) async {
    state = on;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefKey, on);
  }
}

/// Whether the admin asked to see drafts on this phone.
final draftsPreviewEnabledProvider =
    StateNotifierProvider<DraftsPreviewNotifier, bool>(
  (_) => DraftsPreviewNotifier(),
);

Stream<Map<String, Map<String, dynamic>>> _draftDocs(String collection) =>
    FirebaseFirestore.instance.collection(collection).snapshots().map(
          (s) => {for (final d in s.docs) d.id: d.data()},
        );

/// Draft documents from Firestore, only when the user is an admin and
/// the switch is on; otherwise no overrides at all.
final draftsOverlayProvider = StreamProvider<PreviewOverrides>((ref) {
  final enabled = ref.watch(draftsPreviewEnabledProvider);
  final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
  if (!enabled || !isAdmin) return Stream.value(PreviewOverrides.none);
  return Rx.combineLatest3(
    _draftDocs('drafts_products'),
    _draftDocs('drafts_dishes'),
    _draftDocs('drafts_config'),
    (Map<String, Map<String, dynamic>> p, Map<String, Map<String, dynamic>> d,
            Map<String, Map<String, dynamic>> c) =>
        PreviewOverrides(
      products: p,
      dishes: d,
      config: {
        for (final e in c.entries)
          e.key: {
            for (final f in e.value.entries)
              if (f.key != '_draft') f.key: f.value,
          },
      },
      label: 'Console drafts',
    ),
  );
});

/// What the catalogue and config providers actually apply: the console's
/// iframe overrides in the preview build, the on-phone drafts otherwise.
final effectiveOverridesProvider = Provider<PreviewOverrides>((ref) {
  if (kPreviewMode) return ref.watch(previewOverridesProvider);
  return ref.watch(draftsOverlayProvider).valueOrNull ?? PreviewOverrides.none;
});
