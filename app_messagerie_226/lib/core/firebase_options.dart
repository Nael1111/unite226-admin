// Généré manuellement à partir des clés Firebase du projet unite226-app
// Project ID : unite226-app | Project Number : 80911235759

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web non supporté pour cette app mobile.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Plateforme non supportée : $defaultTargetPlatform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJCh1mrYVOnY8Nn2u-_ZTgPKbkm6o3104',
    appId: '1:80911235759:android:e0fc444fb1f827ac91725a',
    messagingSenderId: '80911235759',
    projectId: 'unite226-app',
    storageBucket: 'unite226-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMQU9h-WF0HvL6plg6hvwDVkFRnthJ6cM',
    appId: '1:80911235759:ios:76c502defd42fc7f91725a',
    messagingSenderId: '80911235759',
    projectId: 'unite226-app',
    storageBucket: 'unite226-app.firebasestorage.app',
    bundleId: 'com.tonorganisation.appMessagerie226',
  );
}
