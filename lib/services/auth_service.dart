import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiService _api = ApiService.instance;

  String? _token;
  String? _username;
  String? _email;

  bool get isLoggedIn => _token != null;

  String? get currentUsername => _username;

  String? get currentUserEmail => _email;

  String? get token => _token;

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        'login/',
        {
          'email': email.trim(),
          'password': password,
        },
      );

      debugPrint('LOGIN RESPONSE: $response');

      final accessToken = response['token'];

      if (accessToken == null ||
          accessToken.toString().isEmpty) {
        debugPrint('ERROR: Access token missing from response');
        return 'Login failed: access token was not received.';
      }

      _token = accessToken.toString();

      _api.token = _token;

      final user = response['user'];

      if (user != null) {
        _username = user['username'];
        _email = user['email'];
      }

      debugPrint('Login successful');
      debugPrint('Username: $_username');
      debugPrint('Email: $_email');
      debugPrint('Token received: ${_token != null}');
      debugPrint('Token length: ${_token!.length}');

      return null;
    } catch (e) {
      debugPrint('Login failed: $e');
      return 'Invalid email or password.';
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _api.get('profile/');

    return Map<String, dynamic>.from(response);
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _email = null;
    _api.token = null;

    debugPrint('User logged out');
  }
}