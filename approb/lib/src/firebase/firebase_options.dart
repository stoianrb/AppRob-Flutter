import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configurare Firebase pentru platforme diferite
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          '❌ FirebaseOptions nu este configurat pentru această platformă.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCN5UVZxIOb7AGEsIFaypMCggXWbnuR0Og',
    appId: '1:370951925173:web:b54753ecdf7d2b38dc3dfc',
    messagingSenderId: '370951925173',
    projectId: 'approb-35bdf',
    authDomain: 'approb-35bdf.firebaseapp.com',
    storageBucket: 'approb-35bdf.appspot.com',
    measurementId: 'G-BY16EYTL91',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5Jg619r93oarzO26H1XcsqYIPpugcCGc',
    appId: '1:370951925173:android:9b36748101bbce8cdc3dfc',
    messagingSenderId: '370951925173',
    projectId: 'approb-35bdf',
    storageBucket: 'approb-35bdf.appspot.com',
  );
}
