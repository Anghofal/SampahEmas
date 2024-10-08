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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCW488745M3fPRHnLy_SiT_DCeZThK8R0c',
    appId: '1:492435527776:web:92c8dc45d065f0344bcb05',
    messagingSenderId: '492435527776',
    projectId: 'sampahemas-381bb',
    authDomain: 'sampahemas-381bb.firebaseapp.com',
    storageBucket: 'sampahemas-381bb.appspot.com',
    measurementId: 'G-MXM9WPVHP3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkrOvMSIFG_dbCWUzI8_cUU0Fj5z2lbxo',
    appId: '1:492435527776:android:17873d7b6fb92e1a4bcb05',
    messagingSenderId: '492435527776',
    projectId: 'sampahemas-381bb',
    storageBucket: 'sampahemas-381bb.appspot.com',
  );
}
