// GENERATED FILE (template)
// Remplacez les valeurs ci-dessous par celles fournies dans la console Firebase
// (Project settings -> General -> Votre app Web / Android / iOS -> Config)

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Remplacez les valeurs ci-dessous par celles de votre projet Firebase.
  // Pour une génération automatique, utilisez `flutterfire configure`.

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCVcVqNC5LwAV8Xn8BruKvvEyLqlI8Gni8',
    authDomain: 'flutter-todo-web-305fb.firebaseapp.com',
    projectId: 'flutter-todo-web-305fb',
    storageBucket: 'flutter-todo-web-305fb.firebasestorage.app',
    messagingSenderId: '38102823585',
    appId: '1:38102823585:web:6ea386178d7f409e9df6e0',
    measurementId: null,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT.appspot.com',
    iosBundleId: 'com.example.app',
  );
}
