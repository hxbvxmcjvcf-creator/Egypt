// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Web ───────────────────────────────────────────────────────────────────
  // Used for IDX web preview
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyARZmFDFq4samoV61JCn3NWf6GSeseMx1Y',
    appId:             '1:1057922283011:web:3359be3e1d338592694036',
    messagingSenderId: '1057922283011',
    projectId:         'maxstall',
    databaseURL:       'https://maxstall-default-rtdb.firebaseio.com',
    storageBucket:     'maxstall.firebasestorage.app',
    authDomain:        'maxstall.firebaseapp.com',
  );

  // ── Android ───────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyARZmFDFq4samoV61JCn3NWf6GSeseMx1Y',
    appId:             '1:1057922283011:android:3359be3e1d338592694036',
    messagingSenderId: '1057922283011',
    projectId:         'maxstall',
    databaseURL:       'https://maxstall-default-rtdb.firebaseio.com',
    storageBucket:     'maxstall.firebasestorage.app',
  );

  // ── iOS ───────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'AIzaSyA389O0LSajMaXirVepeeIKdk_u8keE2Mg',
    appId:             '1:1057922283011:ios:e20874f2850a6d2a694036',
    messagingSenderId: '1057922283011',
    projectId:         'maxstall',
    databaseURL:       'https://maxstall-default-rtdb.firebaseio.com',
    storageBucket:     'maxstall.firebasestorage.app',
    iosBundleId:       'com.example.eduAuth31',
    iosClientId:
        '1057922283011-5tde5a2343kqvm18481tmbc5m5qvi2fq.apps.googleusercontent.com',
  );
}
