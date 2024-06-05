import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
        case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }


  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBbHMg0TB3zuKdDaX6R28pmV_OSBN-VbHA',
    appId: '1:758433065251:web:e3e376dc56645f8ba78496',
    messagingSenderId: '758433065251',
    projectId: 'kangleimart-2bf1f',
    authDomain: 'kangleimart-2bf1f.firebaseapp.com',
    storageBucket: 'kangleimart-2bf1f.appspot.com',
    measurementId: 'G-134RG123M2',
    databaseURL: "https://kangleimart-2bf1f.firebaseio.com",



  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbHMg0TB3zuKdDaX6R28pmV_OSBN-VbHA',
    appId: '1:758433065251:android:89b224826d5256b0a78496',
    messagingSenderId: '758433065251',
    projectId: 'kangleimart-2bf1f',
    storageBucket: 'kangleimart-2bf1f.appspot.com',
    authDomain: "kangleimart-2bf1f.firebaseapp.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbHMg0TB3zuKdDaX6R28pmV_OSBN-VbHA',
    appId: '1:758433065251:ios:e3e376dc56645f8ba78496',
    messagingSenderId: '758433065251',
    projectId: 'kangleimart-2bf1f',
    storageBucket: 'kangleimart-2bf1f.appspot.com',
    androidClientId: '378200727300-7ie7cqpqllqj9k6it22kcse4j4f5nonk.apps.googleusercontent.com',
    iosClientId: '378200727300-7ie7cqpqllqj9k6it22kcse4j4f5nonk.apps.googleusercontent.com',
    iosBundleId: 'com.kangleiinovations.kangleimart',
  );
}