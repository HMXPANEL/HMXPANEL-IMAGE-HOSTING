import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';
import '../../../core/errors/exceptions.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository()
      : _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser.fromFirebase(user);
    });
  }

  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser.fromFirebase(user);
  }

  Future<AppUser> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AppUser.fromFirebase(credential.user);
    } on FirebaseAuthException catch (e) {
      throw firebaseExceptionHandler(message: e.message ?? 'Login failed', code: e.code);
    }
  }

  Future<AppUser> createAccount(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return AppUser.fromFirebase(credential.user);
    } on FirebaseAuthException catch (e) {
      throw firebaseExceptionHandler(message: e.message ?? 'Signup failed', code: e.code);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
