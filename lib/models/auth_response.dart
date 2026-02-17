import 'user.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final User? user;
  final String? error;

  AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.user,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Check if data is present and extract token/user
    final data = json['data'] as Map<String, dynamic>?;
    
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      token: data?['token'],
      user: data != null ? User.fromJson(data) : null,
      error: json['error'],
    );
  }
}
