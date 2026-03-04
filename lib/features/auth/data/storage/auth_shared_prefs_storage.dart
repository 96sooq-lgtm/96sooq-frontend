import 'package:_96_sooq/features/auth/data/models/auth_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSharedPrefsStorage {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyAuthUserJson = 'auth_user_json';

  Future<void> saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAuthUserJson, user.toJsonString());
  }

  Future<AuthUser?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyAuthUserJson);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return AuthUser.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyAuthUserJson);
    await prefs.setBool(keyIsLoggedIn, false);
  }
}
