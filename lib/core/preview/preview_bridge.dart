/// postMessage bridge between the console and the embedded preview build.
/// Real implementation on web, no-op elsewhere.
export 'preview_bridge_stub.dart'
    if (dart.library.html) 'preview_bridge_web.dart';
