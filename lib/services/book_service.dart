import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class BookService {
  static const String _baseUrl = 'http://localhost:8080/api/books';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Book>> getBooks({int page = 0, int size = 10}) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/search/?query=$query'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }

  // Placeholder for other CRUD operations
}
