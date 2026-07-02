import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static Future<FirebaseApp> initialize() async {
    return Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAOpMPc3fCPesdp9lJ5Xgg34nZGPaYJi3o',
        authDomain: 'hmx-image-hosting.firebaseapp.com',
        projectId: 'hmx-image-hosting',
        storageBucket: 'hmx-image-hosting.firebasestorage.app',
        messagingSenderId: '1099065658554',
        appId: '1:1099065658554:web:ece8643fe2578ae2130683',
      ),
    );
  }
}
