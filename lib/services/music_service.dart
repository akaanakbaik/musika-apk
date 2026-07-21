import 'dart:collection';
import '../models/song.dart';
import 'api_service.dart';

class MusicService {
  final ApiService _api = ApiService();
  final LinkedHashMap<String, List<Song>> _searchCache = LinkedHashMap();
  static const int _maxCacheEntries = 20;
  static const List<String> _searchSources = ['youtube', 'spotify', 'apple', 'soundcloud'];

  Future<Map<String, dynamic>> rawSearch(String query, {String source = 'all'}) async {
    return await _api.get('/api/music/search', query: {
      'q': query,
      'source': source,
    }, auth: false);
  }

  Future<Map<String, dynamic>> searchSource(String source, String query) async {
    return await _api.get('/api/music/search/$source', query: {
      'q': query,
    }, auth: false);
  }

  Future<Map<String, dynamic>> download(String url, {String source = 'youtube'}) async {
    return await _api.get('/api/music/download', query: {
      'url': url,
      'source': source,
    }, auth: false);
  }

  Future<Map<String, dynamic>> prepare(String url, {String source = 'youtube', String? videoId}) async {
    return await _api.get('/api/music/prepare', query: {
      'url': url,
      'source': source,
      if (videoId != null) 'videoId': videoId,
    }, auth: false);
  }

  Future<Map<String, dynamic>> getRecommendations() async {
    return await _api.get('/api/music/recommendations', auth: false);
  }

  bool _isGoodQuality(Song song) {
    final durationSec = _parseDuration(song.duration);
    return song.title.isNotEmpty &&
        song.artist.isNotEmpty &&
        song.artist != 'Unknown Artist' &&
        durationSec > 30;
  }

  int _parseDuration(String duration) {
    if (duration.isEmpty) return 0;
    final parts = duration.split(':');
    if (parts.length == 2) {
      return int.tryParse(parts[0])! * 60 + int.tryParse(parts[1]) ?? 0;
    }
    if (parts.length == 3) {
      return int.tryParse(parts[0])! * 3600 + int.tryParse(parts[1])! * 60 + int.tryParse(parts[2]) ?? 0;
    }
    return int.tryParse(duration) ?? 0;
  }

  List<Song> _deduplicate(List<Song> songs) {
    final seen = <String>{};
    final result = <Song>[];
    for (final song in songs) {
      final key = '${song.source}:${song.videoId}';
      if (seen.add(key)) {
        result.add(song);
      }
    }
    return result;
  }

  void _cacheResult(String query, List<Song> songs) {
    if (_searchCache.length >= _maxCacheEntries) {
      _searchCache.remove(_searchCache.keys.first);
    }
    _searchCache[query] = songs;
  }

  Future<List<Song>> smartSearch(String query) async {
    if (_searchCache.containsKey(query)) {
      final cached = _searchCache[query]!;
      if (cached.isNotEmpty) return cached;
    }

    final allSongs = <Song>[];
    final results = await rawSearch(query, source: 'all');

    if (results['success'] == true) {
      final resultMap = results['results'] as Map<String, dynamic>? ?? {};
      for (final src in _searchSources) {
        final items = resultMap[src] as List<dynamic>? ?? [];
        final songs = items
            .map((e) => Song.fromJson(e as Map<String, dynamic>))
            .where(_isGoodQuality)
            .toList();
        allSongs.addAll(songs);
      }
    } else {
      for (final src in _searchSources) {
        final fallbackRes = await searchSource(src, query);
        if (fallbackRes['success'] == true) {
          final items = fallbackRes['results'] as List<dynamic>? ?? [];
          final songs = items
              .map((e) => Song.fromJson(e as Map<String, dynamic>))
              .where(_isGoodQuality)
              .toList();
          allSongs.addAll(songs);
        }
      }
    }

    final uniqueSongs = _deduplicate(allSongs);
    _cacheResult(query, uniqueSongs);
    return uniqueSongs;
  }

  Future<List<Song>> searchSongs(String query, {String source = 'all'}) async {
    if (source == 'all') return smartSearch(query);
    final res = await searchSource(source, query);
    if (res['success'] != true) return [];
    final items = res['results'] as List<dynamic>? ?? [];
    return items
        .map((e) => Song.fromJson(e as Map<String, dynamic>))
        .where(_isGoodQuality)
        .toList();
  }

  void clearCache() {
    _searchCache.clear();
  }
}
