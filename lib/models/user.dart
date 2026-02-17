class User {
  final int id;
  final String username;
  final String? fullName;

  User({
    required this.id,
    required this.username,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['user_id'] ?? 0, // API returns user_id in login response, id in /me
      username: json['username'] ?? '',
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
    };
  }
}
