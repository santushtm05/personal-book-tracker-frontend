class AppConstants {
  // Base API URL
  // For Android Emulator, use http://10.0.2.2:8080/api
  // For iOS Simulator/Web/Physical devices, use http://localhost:8080/api or your machine IP
  static const String apiBaseUrl = 'http://localhost:8080/api';

  // Auth Endpoints
  static const String authUrl = '$apiBaseUrl/auth';
  
  // Book Endpoints
  static const String booksUrl = '$apiBaseUrl/books';
  
  // Tag Endpoints
  static const String tagsUrl = '$apiBaseUrl/tags';
}
