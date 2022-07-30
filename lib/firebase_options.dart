// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhwp6S32aklQyrw9XgWTqT4ogD4L5Bvco',
    appId: '1:484437078385:android:8b86280382ce75d3e646d0',
    messagingSenderId: '484437078385',
    projectId: 'ponshu-ff7ee',
    storageBucket: 'ponshu-ff7ee.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDv1Xomo1rGRvQBWGtHqxdL2G0-ShJ1GA0',
    appId: '1:484437078385:ios:b9e11fd0185cc59fe646d0',
    messagingSenderId: '484437078385',
    projectId: 'ponshu-ff7ee',
    storageBucket: 'ponshu-ff7ee.appspot.com',
    androidClientId: '484437078385-a4rq7phr518jvekn94rgpbhv44p20s0b.apps.googleusercontent.com',
    iosClientId: '484437078385-b5g69dodecrdd3s4g25fafih76vnia60.apps.googleusercontent.com',
    iosBundleId: 'com.highcom.growingSake',
  );
}