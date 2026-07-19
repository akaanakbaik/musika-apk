class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int songCount;
  final bool isPublic;
  final String? userId;
  final String? username;
  final String createdAt;
  final List<dynamic>? songs;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.songCount = 0,
    this.isPublic = false,
    this.userId,
    this.username,
    this.createdAt = '',
    this.songs,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? 'Untitled',
      description: json['description'],
      coverUrl: json['cover_url'] ?? json['coverUrl'] ?? json['thumbnail'],
      songCount: json['song_count'] ?? json['songCount'] ?? json['_count']?['songs'] ?? 0,
      isPublic: json['is_public'] ?? json['isPublic'] ?? false,
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      username: json['username'] ?? json['user']?['username'],
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      songs: json['songs'],
    );
  }
}
