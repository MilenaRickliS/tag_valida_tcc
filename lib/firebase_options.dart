
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
    apiKey: 'AIzaSyAU5ez75gPv60VJFOT9uZXbj-F6dhv-gMk',
    appId: '1:448745840564:web:a6323ac65ecc8d6d171ce1',
    messagingSenderId: '448745840564',
    projectId: 'tagvalida',
    authDomain: 'tagvalida.firebaseapp.com',
    storageBucket: 'tagvalida.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1kOJW0Xx_jTGZprwEPQ-fXhC3BWHOs9g',
    appId: '1:448745840564:android:bee8c3240f730e4d171ce1',
    messagingSenderId: '448745840564',
    projectId: 'tagvalida',
    storageBucket: 'tagvalida.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDC40jiNf9EWXHgf0DOOD_oHuJRyvQM4cI',
    appId: '1:448745840564:ios:52eb8fc053592381171ce1',
    messagingSenderId: '448745840564',
    projectId: 'tagvalida',
    storageBucket: 'tagvalida.firebasestorage.app',
    iosBundleId: 'com.example.tagValida',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDC40jiNf9EWXHgf0DOOD_oHuJRyvQM4cI',
    appId: '1:448745840564:ios:52eb8fc053592381171ce1',
    messagingSenderId: '448745840564',
    projectId: 'tagvalida',
    storageBucket: 'tagvalida.firebasestorage.app',
    iosBundleId: 'com.example.tagValida',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAU5ez75gPv60VJFOT9uZXbj-F6dhv-gMk',
    appId: '1:448745840564:web:8611272025f3085e171ce1',
    messagingSenderId: '448745840564',
    projectId: 'tagvalida',
    authDomain: 'tagvalida.firebaseapp.com',
    storageBucket: 'tagvalida.firebasestorage.app',
  );

}