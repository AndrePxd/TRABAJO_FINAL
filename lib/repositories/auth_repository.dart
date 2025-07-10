import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;

  // Stream que emite el User? actual (null = no logueado)
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Registro
  Future<UserCredential> signUp({
    required String email,
    required String pass,
  }) => _auth.createUserWithEmailAndPassword(email: email, password: pass);

  // Login
  Future<UserCredential> signIn({
    required String email,
    required String pass,
  }) => _auth.signInWithEmailAndPassword(email: email, password: pass);

  // Logout
  Future<void> signOut() => _auth.signOut();
}
