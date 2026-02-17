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
  late TextEditingController _descriptionController;
  
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
    _descriptionController = TextEditingController(text: widget.book?.description ?? '');
    
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
    _descriptionController.dispose();
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
        'description': _descriptionController.text.trim(),
        'thumbnail_url': _thumbnailController.text.trim(),
        'tags': _selectedTags.map((t) => t.id).toList(), // API expects [1, 3, 2]
      };

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

  void _showAddTagDialog() {
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Tag'),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(labelText: 'Tag Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = tagController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context); // Close dialog
                try {
                  final newTag = await Provider.of<BookProvider>(context, listen: false).createTag(name);
                  if (mounted) {
                    setState(() {
                      _availableTags.add(newTag);
                      _selectedTags.add(newTag);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tag added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add tag: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 5,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _showAddTagDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Tag'),
                  ),
                ],
              ),
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
