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

  Future<bool> register(String username, String password, String fullName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(username, password, fullName);

      if (response.success) {
        // Registration successful, usually we redirect to login or auto-login
        // For now, just return true so UI can navigate
      } else {
        _error = response.message ?? response.error ?? 'Registration Failed';
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

  Future<void> fetchUserDetails() async {
    if (_token == null) return;
    
    try {
      final response = await _authService.getProfile(_token!);
      if (response.success && response.user != null) {
        _user = response.user;
        notifyListeners();
      }
    } catch (e) {
      // Error fetching user details, silent or handle elsewhere
    }
  }

  Future<bool> updateUserDetails(Map<String, dynamic> data) async {
    if (_token == null || _user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(_user!.id, _token!, data);

      if (response.success && response.user != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? response.error ?? 'Update Failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkUsernameAvailability(String username) async {
    return await _authService.checkUsername(username);
  }
}
