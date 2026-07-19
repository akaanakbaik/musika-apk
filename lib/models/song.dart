class Song {
  final String videoId;
  final String title;
  final String thumbnail;
  final String duration;
  final String url;
  final String source;
  final String artist;
  final String? album;
  final String? releaseDate;

  Song({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.url,
    required this.source,
    required this.artist,
    this.album,
    this.releaseDate,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      videoId: json['videoId'] ?? json['video_id'] ?? '',
      title: json['title'] ?? 'Unknown',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? '0:00',
      url: json['url'] ?? '',
      source: json['source'] ?? 'unknown',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'],
      releaseDate: json['releaseDate'],
    );
  }

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'title': title,
    'thumbnail': thumbnail,
    'duration': duration,
    'url': url,
    'source': source,
    'artist': artist,
    'album': album,
    'releaseDate': releaseDate,
  };
}
