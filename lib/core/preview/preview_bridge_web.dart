// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

/// Web: the console embeds the preview build in an iframe and talks to it
/// with `postMessage`. Only messages from the same origin are accepted.
void listenForPreviewMessages(void Function(Map<String, dynamic>) onMessage) {
  html.window.onMessage.listen((event) {
    if (event.origin != html.window.location.origin) return;
    final data = event.data;
    Map<String, dynamic>? map;
    if (data is Map) {
      map = Map<String, dynamic>.from(data);
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) map = Map<String, dynamic>.from(decoded);
      } catch (_) {
        return;
      }
    }
    if (map != null && map['type'] is String && (map['type'] as String).startsWith('wb-preview')) {
      onMessage(map);
    }
  });
}

void postToParent(Map<String, dynamic> message) {
  final parent = html.window.parent;
  if (parent == null) return;
  parent.postMessage(jsonEncode(message), html.window.location.origin);
}

Map<String, String> initialQuery() => Uri.base.queryParameters;
