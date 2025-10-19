import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
        return ios;
      case TargetPlatform.macOS:
        return macOS;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI command for your platform',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for fuchsia - '
          'you can reconfigure this by running the FlutterFire CLI command for your platform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDeGlgOIDAOeg_WoXcdxIv6QlwHDFokEuA',
    appId: '1:229577295263:web:5769b68cdc0758770529aa',
    messagingSenderId: '229577295263',
    projectId: 'bogazici-barter',
    authDomain: 'bogazici-barter.firebaseapp.com',
    storageBucket: 'bogazici-barter.firebasestorage.app',
    measurementId: 'G-GCXH7TPZFC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApru-QZt7nsdYv-u4xa6NXWmcsLtkEm6E',
    appId: '1:229577295263:android:544e2e3c3c6a67760529aa',
    messagingSenderId: '229577295263',
    projectId: 'bogazici-barter',
    storageBucket: 'bogazici-barter.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDa8VHIPrCDODjeGnz9jLSZTWix0LEUXRQ',
    appId: '1:229577295263:ios:6642f9c9f05408530529aa',
    messagingSenderId: '229577295263',
    projectId: 'bogazici-barter',
    storageBucket: 'bogazici-barter.firebasestorage.app',
    androidClientId:
        '229577295263-bglejqrhd6fg18e70jmeu36m4as15p6p.apps.googleusercontent.com',
    iosClientId:
        '229577295263-9efl3o1jk1uufrhq2vtoc57k7rkt6b12.apps.googleusercontent.com',
    iosBundleId: 'com.bogazicibarter.barterQween',
  );

  static const FirebaseOptions macOS = FirebaseOptions(
    apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789012:macos:abcdefghijklmnop',
    messagingSenderId: '123456789012',
    projectId: 'bogazici-barter-app',
    storageBucket: 'bogazici-barter-app.appspot.com',
    iosBundleId: 'com.bogazici.barterapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789012:windows:abcdefghijklmnop',
    messagingSenderId: '123456789012',
    projectId: 'bogazici-barter-app',
    storageBucket: 'bogazici-barter-app.appspot.com',
  );
}
