import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';

/// True in the console's mobile-preview build
/// (`flutter build web --dart-define=WB_PREVIEW=true`).
const bool kPreviewMode = bool.fromEnvironment('WB_PREVIEW');

/// Draft documents layered over the live catalogue and config. Used by the
/// console preview (unsaved edits sent by the editor) and by the on-phone
/// "Preview console drafts" switch for admins. Never written to Firestore
/// from here.
class PreviewOverrides {
  const PreviewOverrides({
    this.products = const {},
    this.dishes = const {},
    this.config = const {},
    this.label,
  });

  static const none = PreviewOverrides();

  /// Full documents by id (a document with `archived: true` hides the item).
  final Map<String, Map<String, dynamic>> products;
  final Map<String, Map<String, dynamic>> dishes;

  /// Config document content by document id (e.g. `pairingRules`).
  final Map<String, Map<String, dynamic>> config;

  /// Short description shown in the preview banner ("Unsaved edit", "Drafts").
  final String? label;

  bool get isEmpty => products.isEmpty && dishes.isEmpty && config.isEmpty;

  /// Applies overrides to a list of raw catalogue documents (keyed by `id`).
  List<Map<String, dynamic>> applyTo(
    String collection,
    List<Map<String, dynamic>> live,
  ) {
    final over = collection == 'products' ? products : dishes;
    if (over.isEmpty) return live;
    final out = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final doc in live) {
      final id = doc['id'] as String?;
      if (id != null && over.containsKey(id)) {
        out.add({...doc, ...over[id]!, 'id': id});
        seen.add(id);
      } else {
        out.add(doc);
      }
    }
    for (final e in over.entries) {
      if (!seen.contains(e.key)) out.add({...e.value, 'id': e.key});
    }
    return out;
  }

  static PreviewOverrides fromMessage(Map<String, dynamic> m) {
    Map<String, Map<String, dynamic>> docs(Object? v) => {
          if (v is Map)
            for (final e in v.entries)
              if (e.value is Map)
                e.key.toString(): Map<String, dynamic>.from(e.value as Map),
        };
    return PreviewOverrides(
      products: docs(m['products']),
      dishes: docs(m['dishes']),
      config: docs(m['config']),
      label: m['label'] as String?,
    );
  }
}

final previewOverridesProvider =
    StateProvider<PreviewOverrides>((_) => PreviewOverrides.none);

/// Palate profile forced by the console preview ("test as Crisp Purist").
/// Null means: use the signed-in user's own profile.
final previewPalateProvider = StateProvider<PalateProfile?>((_) => null);

/// `new` hides personal history (no uid), `returning` uses the signed-in
/// admin's own data. Only read in preview mode.
final previewUserStateProvider = StateProvider<String>((_) => 'returning');
