import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);

      if (response.success && response.token != null) {
        _token = response.token;
        _user = response.user;
        
        // Persist token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        
        // If user data is returned, we could persist it too, or fetch /me
        // For now, trusting login response
      } else {
        _error = response.message ?? response.error ?? 'Login Failed';
      }
      
      _isLoading = false;
      notifyListeners();
      return response.success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
