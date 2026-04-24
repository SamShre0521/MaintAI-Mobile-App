import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userName='user_name';
  static const _role='user_role';
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.deleteAll();
  }
  Future<void> saveUserName(String userName) async {
    await _storage.write(key: _userName, value: userName);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _userName);
    
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _role, value: role);
  }
  Future<String?> getUserRole() async {
    return await _storage.read(key: _role);
  }
}