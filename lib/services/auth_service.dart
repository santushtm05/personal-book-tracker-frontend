import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';

class AuthService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator/Web
  // Ideally this should be configurable.
  static const String _apiBase = 'http://localhost:8080/api';
  static const String _baseUrl = '$_apiBase/auth'; 

  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(body);
      } else {
        return AuthResponse(
          success: false, 
          message: body['message'] ?? 'Login failed',
          error: body['error'] ?? 'Unknown error'
        );
      }
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<AuthResponse> register(String username, String password, String fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'full_name': fullName,
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return AuthResponse.fromJson(body);
      } else {
        return AuthResponse(
          success: false,
          message: body['message'] ?? 'Registration failed',
          error: body['error']
        );
      }
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<AuthResponse> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBase/auth/get-authenticated-user-details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(body);
      } else {
        return AuthResponse(
          success: false,
          message: body['message'],
          error: body['error'],
        );
      }
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<AuthResponse> updateProfile(int userId, String token, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$_apiBase/users/update/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(body);
      } else {
        return AuthResponse(
          success: false,
          message: body['message'],
          error: body['error'],
        );
      }
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<bool> checkUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/username-available?username=$username'),
      );
      final body = jsonDecode(response.body);
      return body['success'] == true && body['message'] == 'Username Available!';
    } catch (e) {
      return false;
    }
  }
}
