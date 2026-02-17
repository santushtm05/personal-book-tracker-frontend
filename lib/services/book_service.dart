import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/tag.dart';

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

  Future<Book> addBook(Map<String, dynamic> bookData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/create'),
      headers: headers,
      body: jsonEncode(bookData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to add book');
    }
  }

  Future<Book> updateBook(int id, Map<String, dynamic> bookData) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$_baseUrl/update/$id'),
      headers: headers,
      body: jsonEncode(bookData),
    );

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to update book');
    }
  }

  Future<void> deleteBook(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/delete/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete book');
    }
  }

  Future<Tag> createTag(String tagName) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/tags/create'),
      headers: headers,
      body: jsonEncode({'tag_name': tagName}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Tag.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create tag');
    }
  }

  Future<List<Tag>> getTags() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/tags/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => Tag.fromJson(json)).toList();
    } else {
      // Fallback or empty list if tags endpoint fails or doesn't exist yet
      return []; 
    }
  }
}
