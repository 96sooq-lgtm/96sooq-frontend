import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSecureStorage {
  AuthSecureStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const String keyAccessToken = 'auth_access_token';
  static const String keyTokenType = 'auth_token_type';

  Future<void> saveToken({
    required String accessToken,
    required String tokenType,
  }) async {
    await _secureStorage.write(key: keyAccessToken, value: accessToken);
    await _secureStorage.write(key: keyTokenType, value: tokenType);
  }

  Future<String?> readAccessToken() async {
    return _secureStorage.read(key: keyAccessToken);
  }

  Future<String?> readTokenType() async {
    return _secureStorage.read(key: keyTokenType);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: keyAccessToken);
    await _secureStorage.delete(key: keyTokenType);
  }
}
