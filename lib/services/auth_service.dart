import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usernameKey = 'saved_username';
  static const _passwordKey = 'saved_password';
  static const _loggedInKey = 'is_logged_in';

  Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  Future<bool> signup({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_loggedInKey, true);
    return true;
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString(_usernameKey);
    final savedPassword = prefs.getString(_passwordKey);

    if (savedUsername == username && savedPassword == password) {
      await prefs.setBool(_loggedInKey, true);
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }
}
