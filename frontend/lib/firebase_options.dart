// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA9DUm_aNpEyuFDVuaEC8i82J9l1BmW2KU',
    appId: '1:881487619712:web:e581a828fdca49952d6865',
    messagingSenderId: '881487619712',
    projectId: 'hackthebrain-healthcare-ai',
    authDomain: 'hackthebrain-healthcare-ai.firebaseapp.com',
    databaseURL: 'https://hackthebrain-healthcare-ai-default-rtdb.firebaseio.com',
    storageBucket: 'hackthebrain-healthcare-ai.firebasestorage.app',
    measurementId: 'G-MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9DUm_aNpEyuFDVuaEC8i82J9l1BmW2KU',
    appId: '1:881487619712:android:app_id_here',
    messagingSenderId: '881487619712',
    projectId: 'hackthebrain-healthcare-ai',
    authDomain: 'hackthebrain-healthcare-ai.firebaseapp.com',
    databaseURL: 'https://hackthebrain-healthcare-ai-default-rtdb.firebaseio.com',
    storageBucket: 'hackthebrain-healthcare-ai.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9DUm_aNpEyuFDVuaEC8i82J9l1BmW2KU',
    appId: '1:881487619712:ios:app_id_here',
    messagingSenderId: '881487619712',
    projectId: 'hackthebrain-healthcare-ai',
    authDomain: 'hackthebrain-healthcare-ai.firebaseapp.com',
    databaseURL: 'https://hackthebrain-healthcare-ai-default-rtdb.firebaseio.com',
    storageBucket: 'hackthebrain-healthcare-ai.firebasestorage.app',
    iosBundleId: 'com.hackthebrain.healthcareai.healthcareAiApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA9DUm_aNpEyuFDVuaEC8i82J9l1BmW2KU',
    appId: '1:881487619712:ios:app_id_here',
    messagingSenderId: '881487619712',
    projectId: 'hackthebrain-healthcare-ai',
    authDomain: 'hackthebrain-healthcare-ai.firebaseapp.com',
    databaseURL: 'https://hackthebrain-healthcare-ai-default-rtdb.firebaseio.com',
    storageBucket: 'hackthebrain-healthcare-ai.firebasestorage.app',
    iosBundleId: 'com.hackthebrain.healthcareai.healthcareAiApp',
  );
} 