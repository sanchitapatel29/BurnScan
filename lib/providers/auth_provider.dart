import 'package:burn_scan/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  bool _isLoggedIn = false;
  bool _isReady = false;
  bool _isLoading = false;
  String? _error;
  String? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isReady => _isReady;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUser => _currentUser;

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    _isLoggedIn = await _authService.hasSession();
    _currentUser = await _authService.getCurrentUser();
    _isReady = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _authService.login(
      username: username.trim(),
      password: password,
    );

    _isLoggedIn = success;
    if (!success) {
      _error = 'Invalid username or password.';
      _currentUser = null;
    } else {
      _currentUser = username.trim();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> signup(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _authService.signup(
      username: username.trim(),
      password: password,
    );

    if (!success) {
      _error = 'Username already exists.';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}
