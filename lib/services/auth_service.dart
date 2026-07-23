import 'package:flutter/foundation.dart';

class AuthService {
  bool _loggedIn = false;
  String? _userEmail;

  bool get isLoggedIn => _loggedIn;

  String? get currentUserEmail => _userEmail;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // TODO: Replace with backend authentication.
    await Future.delayed(const Duration(seconds: 1));

    _loggedIn = true;
    _userEmail = email;

    debugPrint('Logged in as $email');

    return true;
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    // TODO: Replace with backend signup.
    await Future.delayed(const Duration(seconds: 1));

    debugPrint('Created account for $email');

    return true;
  }

  Future<void> logout() async {
    _loggedIn = false;
    _userEmail = null;

    debugPrint('User logged out');
  }

  Future<bool> sendOtp(String email) async {
    // TODO: Connect to backend OTP service.
    await Future.delayed(const Duration(seconds: 1));

    debugPrint('OTP sent to $email');

    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    // TODO: Verify OTP with backend.
    await Future.delayed(const Duration(milliseconds: 800));

    debugPrint('OTP verified');

    return true;
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // TODO: Connect to backend reset password API.
    await Future.delayed(const Duration(seconds: 1));

    debugPrint('Password reset for $email');

    return true;
  }
}