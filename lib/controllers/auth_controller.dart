import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registrazione
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Gestisci gli errori specifici
      throw e;
    }
  }

  // Login
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Gestisci gli errori specifici
      throw e;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Verifica lo stato di autenticazione
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
