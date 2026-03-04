import 'package:_96_sooq/features/auth/data/models/auth_user_model.dart';
import 'package:_96_sooq/features/auth/data/storage/auth_secure_storage.dart';
import 'package:_96_sooq/features/auth/data/storage/auth_shared_prefs_storage.dart';
import 'package:_96_sooq/shared/dio_services.dart';

class AuthSessionRepository {
  AuthSessionRepository({
    AuthSecureStorage? secureStorage,
    AuthSharedPrefsStorage? sharedPrefsStorage,
  }) : _secureStorage = secureStorage ?? AuthSecureStorage(),
       _sharedPrefsStorage = sharedPrefsStorage ?? AuthSharedPrefsStorage();

  final AuthSecureStorage _secureStorage;
  final AuthSharedPrefsStorage _sharedPrefsStorage;

  Future<void> persistAuthenticatedSession({
    required String accessToken,
    required String tokenType,
    required AuthUser user,
  }) async {
    await _secureStorage.saveToken(
      accessToken: accessToken,
      tokenType: tokenType,
    );
    await _sharedPrefsStorage.saveUser(user);
    await _sharedPrefsStorage.setLoggedIn(true);
    // Open the auth gate so any queued protected API calls can proceed.
    DioServices.markAuthReady();
  }

  Future<AuthUser?> getCachedUser() {
    return _sharedPrefsStorage.readUser();
  }

  Future<String?> getAccessToken() {
    return _secureStorage.readAccessToken();
  }

  Future<bool> isLoggedIn() async {
    final loggedIn = await _sharedPrefsStorage.isLoggedIn();
    if (!loggedIn) return false;
    final token = await _secureStorage.readAccessToken();
    final result = token != null && token.isNotEmpty;
    // If the user is already logged in on app launch, open the gate
    // so protected API calls don't wait unnecessarily.
    if (result) {
      DioServices.markAuthReady();
    }
    return result;
  }

  Future<void> clearSession() async {
    await _secureStorage.clearToken();
    await _sharedPrefsStorage.clear();
    DioServices.resetAuthGate();
  }
}
