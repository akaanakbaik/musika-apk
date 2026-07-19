class User {
  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'] ?? json['displayName'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      bio: json['bio'],
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'bio': bio,
  };
}
