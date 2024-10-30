// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyCxxSsOMiLTgS2Fk8pcU0o5oaorJO9fSLI',
    appId: '1:795889805736:web:0bd42e9ed1c5a92ddfd59d',
    messagingSenderId: '795889805736',
    projectId: 'scopes-21c04',
    authDomain: 'scopes-21c04.firebaseapp.com',
    storageBucket: 'scopes-21c04.appspot.com',
    measurementId: 'G-MY6TMMN824',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjyzJN7BHb3BAg9RehO0p_lIePkSB6RvY',
    appId: '1:795889805736:android:6f9e87c4a5078970dfd59d',
    messagingSenderId: '795889805736',
    projectId: 'scopes-21c04',
    storageBucket: 'scopes-21c04.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCT8yB9bbZCZ-0bBPJQavxkJJctTkWIRNU',
    appId: '1:795889805736:ios:94341490d460b600dfd59d',
    messagingSenderId: '795889805736',
    projectId: 'scopes-21c04',
    storageBucket: 'scopes-21c04.appspot.com',
    iosBundleId: 'com.example.scope',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCT8yB9bbZCZ-0bBPJQavxkJJctTkWIRNU',
    appId: '1:795889805736:ios:94341490d460b600dfd59d',
    messagingSenderId: '795889805736',
    projectId: 'scopes-21c04',
    storageBucket: 'scopes-21c04.appspot.com',
    iosBundleId: 'com.example.scope',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCxxSsOMiLTgS2Fk8pcU0o5oaorJO9fSLI',
    appId: '1:795889805736:web:f57276453463e19cdfd59d',
    messagingSenderId: '795889805736',
    projectId: 'scopes-21c04',
    authDomain: 'scopes-21c04.firebaseapp.com',
    storageBucket: 'scopes-21c04.appspot.com',
    measurementId: 'G-N8SPGCK4SQ',
  );
}
