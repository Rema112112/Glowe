import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderKeyForAndroidBuild',
    appId: '1:12345:android:12345',
    messagingSenderId: '12345',
    projectId: 'glowe-cb484', // 🌟 Your real project ID from the screenshot!
    storageBucket:
        'glowe-cb484.firebasestorage.app', // 🌟 From your screenshot!
  );
}
