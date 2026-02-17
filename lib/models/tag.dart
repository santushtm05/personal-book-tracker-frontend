class Tag {
  final int id;
  final String tagName;

  Tag({required this.id, required this.tagName});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      tagName: json['tag_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag_name': tagName,
    };
  }
}
