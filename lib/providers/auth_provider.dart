import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    try {
      final token = await ApiService().token;
      if (token != null) {
        final user = await _authService.getCurrentUser();
        if (user != null) _user = user;
      }
    } catch (_) {}
    _initialized = true;
    _loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _authService.login(email, password);
      if (res['success'] == true) {
        _user = User.fromJson(res['user']);
        _loading = false;
        notifyListeners();
        return true;
      }
      _error = res['error'] ?? 'Login failed';
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String username) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _authService.register(email, password, username);
      if (res['success'] == true) {
        _user = User.fromJson(res['user']);
        _loading = false;
        notifyListeners();
        return true;
      }
      _error = res['error'] ?? 'Registration failed';
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _authService.updateProfile(data);
      if (res['success'] == true) {
        _user = User.fromJson(res['user']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
