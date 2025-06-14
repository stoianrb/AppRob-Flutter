import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'; // Import pentru debugPrint

class FirebaseConfig {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Inițializează Firebase
  static Future<void> initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint("✅ Firebase inițializat cu succes!");
      }
    } catch (e) {
      debugPrint("❌ Eroare inițializare Firebase: $e");
    }
  }

  /// Autentificare cu email și parolă
  static Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      debugPrint("❌ Eroare autentificare email: $e");
      return null;
    }
  }

  /// Deconectare utilizator
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Obține utilizatorul curent
  static User? get currentUser => _auth.currentUser;
}
