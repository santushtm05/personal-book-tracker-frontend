import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/tag.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();
  
  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _page = 0;
  final int _size = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  Future<void> fetchBooks({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
      _books = [];
      _isLoading = true;
      notifyListeners();
    } else if (!_hasMore || _isLoadingMore) {
      return;
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final newBooks = await _bookService.getBooks(page: _page, size: _size);
      
      if (newBooks.length < _size) {
        _hasMore = false;
      }
      
      if (refresh) {
        _books = newBooks;
      } else {
        _books.addAll(newBooks);
      }
      
      _page++;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      return fetchBooks(refresh: true);
    }

    _isLoading = true;
    notifyListeners();

    try {
      _books = await _bookService.searchBooks(query);
      _hasMore = false; // Disable pagination for search results in this simple implementation
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBook(Map<String, dynamic> bookData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newBook = await _bookService.addBook(bookData);
      _books.insert(0, newBook); // Add to top of list
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBook(int id, Map<String, dynamic> bookData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedBook = await _bookService.updateBook(id, bookData);
      final index = _books.indexWhere((b) => b.id == id);
      if (index != -1) {
        _books[index] = updatedBook;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBook(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _bookService.deleteBook(id);
      _books.removeWhere((b) => b.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Tag>> fetchTags() async {
    try {
      return await _bookService.getTags();
    } catch (e) {
      // debugPrint('Error fetching tags: $e');
      return [];
    }
  }
}
