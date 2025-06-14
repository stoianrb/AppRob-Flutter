// GENERATED FILE. DO NOT EDIT.
// This is the main Firebase configuration file for all platforms.
// Replace the values only if you re-generate from FlutterFire CLI.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCN5UVZxIOb7AGEsIFaypMCggXWbnuR0Og',
    appId: '1:370951925173:web:5eb3f469b6930b2adc3dfc',
    messagingSenderId: '370951925173',
    projectId: 'approb-35bdf',
    authDomain: 'approb-35bdf.firebaseapp.com',
    storageBucket: 'approb-35bdf.appspot.com',
    measurementId: 'G-CBNMNSE26Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5Jg619r93oarzO26H1XcsqYIPpugcCGc',
    appId: '1:370951925173:android:9b36748101bbce8cdc3dfc',
    messagingSenderId: '370951925173',
    projectId: 'approb-35bdf',
    storageBucket: 'approb-35bdf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIz... (completeaza din Firebase Console dacă ai nevoie de iOS)',
    appId: '1:370951925173:ios:329978b524deb81fdc3dfc',
    messagingSenderId: '370951925173',
    projectId: 'approb-35bdf',
    storageBucket: 'approb-35bdf.appspot.com',
    iosBundleId: 'com.example.approb', // adaptează după nevoie
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIz... (completeaza din Firebase Console dacă ai nevoie de macOS)',
    appId: '1:370951925173:ios:329978b524deb81fdc3dfc',
    messagingSenderId: '370951925173',
    projectId: 'approb-35bdf',
    storageBucket: 'approb-35bdf.appspot.com',
    iosBundleId: 'com.example.approb', // adaptează după nevoie
  );

  static const FirebaseOptions windows = FirebaseOptions(
  apiKey: 'AIzaSyCN5UVZxIOb7AGEsIFaypMCggXWbnuR0Og',
  appId: '1:370951925173:web:226ec37cd840e004dc3dfc',
  messagingSenderId: '370951925173',
  projectId: 'approb-35bdf',
  storageBucket: 'approb-35bdf.appspot.com', // <-- CORECT!
  measurementId: 'G-LYXY2DTEV2',
  );
}
