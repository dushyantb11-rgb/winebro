import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase not configured for ${defaultTargetPlatform.name}. '
          'Run: flutterfire configure',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAoQGXyMdW7E0SWYpp0N2mfHQiWy_pm0J4',
    appId: '1:708385389571:android:98591173586d1c9478a236',
    messagingSenderId: '708385389571',
    projectId: 'winebro',
    storageBucket: 'winebro.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDU3X4094aqM1rI0SEDL1E4_lYvv1oDG_k',
    appId: '1:708385389571:ios:6e132d8110a0a90e78a236',
    messagingSenderId: '708385389571',
    projectId: 'winebro',
    storageBucket: 'winebro.firebasestorage.app',
    iosBundleId: 'com.chv.winebro',
  );
}

