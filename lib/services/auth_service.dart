import 'dart:convert';

import 'package:burn_scan/services/database_service.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService(this._databaseService);

  static const _loggedInKey = 'loggedIn';
  static const _currentUserKey = 'currentUser';

  final DatabaseService _databaseService;

  Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<bool> signup({
    required String username,
    required String password,
  }) async {
    final db = await _databaseService.database;
    final normalizedUsername = username.trim();

    final existingUsers = await db.query(
      DatabaseService.usersTable,
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [normalizedUsername],
      limit: 1,
    );

    if (existingUsers.isNotEmpty) {
      return false;
    }

    await db.insert(
      DatabaseService.usersTable,
      {
        'username': normalizedUsername,
        'password': _hashPassword(password),
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    return true;
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final db = await _databaseService.database;
    final normalizedUsername = username.trim();

    final users = await db.query(
      DatabaseService.usersTable,
      columns: ['username', 'password'],
      where: 'username = ?',
      whereArgs: [normalizedUsername],
      limit: 1,
    );

    if (users.isEmpty) {
      return false;
    }

    final savedPasswordHash = users.first['password'] as String;
    final passwordHash = _hashPassword(password);
    if (savedPasswordHash != passwordHash) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_currentUserKey, normalizedUsername);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    await prefs.remove(_currentUserKey);
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
