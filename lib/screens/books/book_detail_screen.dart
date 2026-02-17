import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import 'add_edit_book_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final int bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        final book = provider.books.firstWhere(
          (b) => b.id == bookId,
          orElse: () => Book(
            id: -1,
            title: 'Not Found',
            author: 'Unknown',
            status: 'UNKNOWN',
            rating: 0,
            pages: 0,
            tags: [],
          ),
        );

        if (book.id == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book Not Found')),
            body: const Center(child: Text('Book not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                  background: book.thumbnailUrl != null && book.thumbnailUrl!.isNotEmpty
                      ? Image.network(
                          book.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(context);
                          },
                        )
                      : _buildPlaceholder(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditBookScreen(book: book),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, provider, book.id),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'by ${book.author}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              book.rating.toString(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.pages, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text('${book.pages} pages'),
                            const SizedBox(width: 16),
                            Chip(
                              label: Text(book.status),
                              backgroundColor: _getStatusColor(book.status),
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Tags',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          children: book.tags.map((tag) {
                            return Chip(
                              label: Text(tag.tagName),
                              backgroundColor: Colors.blue.withValues(alpha: 0.1),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.purple.shade700],
        ),
      ),
      child: const Center(
        child: Icon(Icons.book, size: 80, color: Colors.white54),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'READING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'CREATED':
      default:
        return Colors.blue;
    }
  }

  void _confirmDelete(BuildContext context, BookProvider provider, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await provider.deleteBook(id);
                if (context.mounted) {
                  Navigator.pop(context); // Close detail screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete book: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
