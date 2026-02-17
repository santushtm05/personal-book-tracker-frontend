import 'tag.dart';

class Book {
  final int id;
  final String title;
  final String author;
  final String status;
  final double rating;
  final int pages;
  final String? description; // New
  final String? thumbnailUrl; // Optional
  final List<Tag> tags;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.status,
    required this.rating,
    required this.pages,
    this.description,
    this.thumbnailUrl,
    required this.tags,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    var tagList = json['tags'] as List?;
    List<Tag> tags = tagList != null 
        ? tagList.map((i) => Tag.fromJson(i)).toList() 
        : [];

    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      status: json['status'],
      // Handle int or double for rating
      rating: (json['rating'] as num).toDouble(),
      pages: json['pages'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'status': status,
      'rating': rating,
      'pages': pages,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'tags': tags.map((t) => t.toJson()).toList(),
    };
  }
}
