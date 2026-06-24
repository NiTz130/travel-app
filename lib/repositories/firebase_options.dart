// Dev-only Firebase options for Firebase Emulator recovery.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb, kReleaseMode;

void ensureDevFirebaseOptionsAllowed({bool releaseMode = kReleaseMode}) {
  if (releaseMode) {
    throw StateError(
      'Release builds require real Firebase options; dev emulator placeholder '
      'options must not be used.',
    );
  }
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Only Android is configured for this recovery pass.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'dev-api-key',
    appId: '1:1234567890:android:0000000000000000000000',
    messagingSenderId: '1234567890',
    projectId: 'travel-app-v2-dev',
    databaseURL: 'http://10.0.2.2:9000?ns=travel-app-v2-dev',
    storageBucket: 'travel-app-v2-dev.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'dev-api-key',
    appId: '1:1234567890:web:0000000000000000000000',
    messagingSenderId: '1234567890',
    projectId: 'travel-app-v2-dev',
    authDomain: 'travel-app-v2-dev.firebaseapp.com',
    databaseURL: 'http://localhost:9000?ns=travel-app-v2-dev',
    storageBucket: 'travel-app-v2-dev.appspot.com',
  );
}
