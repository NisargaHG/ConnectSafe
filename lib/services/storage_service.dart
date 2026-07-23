import 'package:flutter/foundation.dart';

class StorageService {
  final Map<String, dynamic> _storage = {};

  Future<void> saveString(String key, String value) async {
    _storage[key] = value;
    debugPrint('Saved String: $key');
  }

  Future<void> saveBool(String key, bool value) async {
    _storage[key] = value;
    debugPrint('Saved Bool: $key');
  }

  Future<void> saveInt(String key, int value) async {
    _storage[key] = value;
    debugPrint('Saved Int: $key');
  }

  Future<String?> getString(String key) async {
    return _storage[key] as String?;
  }

  Future<bool?> getBool(String key) async {
    return _storage[key] as bool?;
  }

  Future<int?> getInt(String key) async {
    return _storage[key] as int?;
  }

  Future<void> remove(String key) async {
    _storage.remove(key);
    debugPrint('Removed: $key');
  }

  Future<void> clear() async {
    _storage.clear();
    debugPrint('Storage cleared');
  }

  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }
}