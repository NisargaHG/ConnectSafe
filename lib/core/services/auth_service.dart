import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseService.instance.auth;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user!.updateDisplayName(
        displayName.trim(),
      );

      if (!credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Unable to create account.';
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );


      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed.';
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  Future<void> sendPasswordResetEmail(
      String email,
      ) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<bool> isEmailVerified() async {
    await reloadUser();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> updateDisplayName(
      String displayName,
      ) async {
    await _auth.currentUser?.updateDisplayName(
      displayName,
    );
  }

  Future<void> updatePassword(
      String newPassword,
      ) async {
    await _auth.currentUser?.updatePassword(
      newPassword,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}