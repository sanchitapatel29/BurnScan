import 'package:burn_scan/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  bool _isLoggedIn = false;
  bool _isReady = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  bool get isReady => _isReady;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoggedIn = await _authService.hasSession();
    _isReady = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _error = null;
    final success = await _authService.login(
      username: username.trim(),
      password: password,
    );
    _isLoggedIn = success;
    if (!success) {
      _error = 'Invalid username or password.';
    }
    notifyListeners();
    return success;
  }

  Future<bool> signup(String username, String password) async {
    _error = null;
    final success = await _authService.signup(
      username: username.trim(),
      password: password,
    );
    _isLoggedIn = success;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}