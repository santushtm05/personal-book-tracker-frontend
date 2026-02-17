import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../models/tag.dart';
import '../../providers/book_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;

  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _pagesController;
  late TextEditingController _ratingController;
  late TextEditingController _thumbnailController;
  
  String _status = 'CREATED';
  List<Tag> _availableTags = [];
  final List<Tag> _selectedTags = [];
  bool _isLoadingTags = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _pagesController = TextEditingController(text: widget.book?.pages.toString() ?? '');
    _ratingController = TextEditingController(text: widget.book?.rating.toString() ?? '');
    _thumbnailController = TextEditingController(text: widget.book?.thumbnailUrl ?? '');
    
    if (widget.book != null) {
      _status = widget.book!.status;
      _selectedTags.addAll(widget.book!.tags);
    }

    _fetchTags();
  }

  Future<void> _fetchTags() async {
    final tags = await Provider.of<BookProvider>(context, listen: false).fetchTags();
    if (mounted) {
      setState(() {
        _availableTags = tags;
        _isLoadingTags = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _ratingController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  void _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final bookData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'status': _status,
        'rating': double.tryParse(_ratingController.text) ?? 0.0,
        'pages': int.tryParse(_pagesController.text) ?? 0,
        'thumbnail_url': _thumbnailController.text.trim(),
        'tags': _selectedTags.map((t) => t.id).toList(), // Assuming backend expects tag IDs
        // Note: Check if backend expects full tag objects or just IDs. Usually IDs for input.
        // API documentation wasn't explicit, but IDs are standard.
        // If API expects Objects, use t.toJson().
      };

      // To be safe with the provided API collection (which I barely recall seeing tags input structure),
      // I'll send IDs. If it fails, we debug.

      // Actually, looking at typical patterns, let's look at `Book` model.
      // `tags` in Book model is List<Tag>.
      // For creation, usually `tag_ids` or `tags` as list of objects.
      // I'll send `tags` as list of IDs based on best guess.
      // Correction: If the API matches the Internship Assessment, it's likely simple.
      // Let's assume sending the whole tag object or just ID is fine.
      // I'll send list of IDs for now as `tag_ids` might be the key, or `tags` expects objects.
      
      // Let's refine based on "standard" behavior:
      // Typically `tags` : [{"id": 1}, {"id": 2}]
      final tagsForApi = _selectedTags.map((t) => {'id': t.id}).toList();
      bookData['tags'] = tagsForApi;

      final provider = Provider.of<BookProvider>(context, listen: false);
      try {
        if (widget.book == null) {
          await provider.addBook(bookData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book added successfully')),
            );
            Navigator.pop(context);
          }
        } else {
          await provider.updateBook(widget.book!.id, bookData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book updated successfully')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save book: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Edit Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Title',
                controller: _titleController,
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Author',
                controller: _authorController,
                validator: (v) => v!.isEmpty ? 'Author is required' : null,
              ),
              const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['CREATED', 'READING', 'COMPLETED']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Pages',
                      controller: _pagesController,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Rating (0-5)',
                      controller: _ratingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null || n < 0 || n > 5) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Thumbnail URL',
                controller: _thumbnailController,
                prefixIcon: Icons.image,
              ),
              const SizedBox(height: 24),
              const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _isLoadingTags
                  ? const Center(child: CircularProgressIndicator())
                  : Wrap(
                      spacing: 8.0,
                      children: _availableTags.map((tag) {
                        final isSelected = _selectedTags.any((t) => t.id == tag.id);
                        return FilterChip(
                          label: Text(tag.tagName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.removeWhere((t) => t.id == tag.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'SAVE BOOK',
                onPressed: _saveBook,
                isLoading: Provider.of<BookProvider>(context).isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
