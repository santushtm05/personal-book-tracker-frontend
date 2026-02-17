import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import 'dart:async';
import 'add_edit_book_screen.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Fetch books on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchBooks(refresh: true);
    });

    // Pagination listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.7) {
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<BookProvider>(context, listen: false).searchBooks(query);
    });
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/'); // Assuming '/' is Login or use direct navigation
    // Since we didn't use named routes in main.dart, we'll push replacement to LoginScreen
    // But better to just pop everything or use a wrapper.
    // For now, let's just clear stack and go to Login.
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by title or author',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    // Dismiss keyboard
                    FocusScope.of(context).unfocus();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                if (bookProvider.isLoading && bookProvider.books.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bookProvider.error != null && bookProvider.books.isEmpty) {
                  return Center(child: Text('Error: ${bookProvider.error}'));
                }

                if (bookProvider.books.isEmpty) {
                  return const Center(child: Text('No books found.'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: bookProvider.books.length + (bookProvider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == bookProvider.books.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final book = bookProvider.books[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: book.thumbnailUrl != null
                            ? Image.network(book.thumbnailUrl!, width: 50, errorBuilder: (c, e, s) => const Icon(Icons.book))
                            : const Icon(Icons.book),
                        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.author),
                            Text('⭐ ${book.rating} | ${book.pages} pages | ${book.status}'),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailScreen(bookId: book.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditBookScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
