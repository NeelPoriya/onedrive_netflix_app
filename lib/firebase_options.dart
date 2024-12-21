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
    apiKey: 'AIzaSyACt5cUgvH2k-YOg4a_8nz5AsnQVPK37Q4',
    appId: '1:247327276985:web:4bdf19bbb44593a4c34068',
    messagingSenderId: '247327276985',
    projectId: 'onedrive-netflix-b7034',
    authDomain: 'onedrive-netflix-b7034.firebaseapp.com',
    storageBucket: 'onedrive-netflix-b7034.firebasestorage.app',
    measurementId: 'G-9MD743G3XH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQyOZSMQno-Ard0VmE0bl-5fCT5A8r6yY',
    appId: '1:247327276985:android:24420a354a2a7c08c34068',
    messagingSenderId: '247327276985',
    projectId: 'onedrive-netflix-b7034',
    storageBucket: 'onedrive-netflix-b7034.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArUN6Q6Yv0W15ts8HdgDCcXlq-FyFSRWI',
    appId: '1:247327276985:ios:11a2af4814689abcc34068',
    messagingSenderId: '247327276985',
    projectId: 'onedrive-netflix-b7034',
    storageBucket: 'onedrive-netflix-b7034.firebasestorage.app',
    iosBundleId: 'com.example.onedriveNetflix',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyArUN6Q6Yv0W15ts8HdgDCcXlq-FyFSRWI',
    appId: '1:247327276985:ios:11a2af4814689abcc34068',
    messagingSenderId: '247327276985',
    projectId: 'onedrive-netflix-b7034',
    storageBucket: 'onedrive-netflix-b7034.firebasestorage.app',
    iosBundleId: 'com.example.onedriveNetflix',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyACt5cUgvH2k-YOg4a_8nz5AsnQVPK37Q4',
    appId: '1:247327276985:web:051746316f14a36dc34068',
    messagingSenderId: '247327276985',
    projectId: 'onedrive-netflix-b7034',
    authDomain: 'onedrive-netflix-b7034.firebaseapp.com',
    storageBucket: 'onedrive-netflix-b7034.firebasestorage.app',
    measurementId: 'G-6TB6P5XR81',
  );
}
