import 'dart:collection';
import 'dart:async';
import '../models/song.dart';
import 'api_service.dart';

class MusicService {
  final ApiService _api = ApiService();

  // ===== SEARCH CACHE =====
  final LinkedHashMap<String, _CacheEntry> _searchCache = LinkedHashMap();
  static const int _maxCacheEntries = 30;
  static const Duration _cacheTtl = Duration(minutes: 5);

  // ===== DEBOUNCE =====
  Timer? _debounceTimer;
  String _lastQuery = '';
  DateTime _lastSearchTime = DateTime.now().subtract(const Duration(seconds: 10));
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  static const Duration _minInterval = Duration(milliseconds: 800);

  // ===== SOURCES =====
  static const List<String> _searchSources = ['youtube', 'spotify', 'apple', 'soundcloud'];

  class _CacheEntry {
    final List<Song> songs;
    final DateTime cachedAt;
    _CacheEntry(this.songs, this.cachedAt);
    bool get isExpired => DateTime.now().difference(cachedAt) > _cacheTtl;
  }

  // ===== SEARCH WITH DEBOUNCE =====
  Future<List<Song>> debouncedSearch(String query, {String source = 'all'}) {
    _debounceTimer?.cancel();
    _lastQuery = query;
    final completer = Completer<List<Song>>();

    // Check debounce interval
    final elapsed = DateTime.now().difference(_lastSearchTime);
    final delay = elapsed < _minInterval
        ? _debounceDelay + (_minInterval - elapsed)
        : _debounceDelay;

    _debounceTimer = Timer(delay, () async {
      if (query != _lastQuery) {
        completer.complete([]);
        return;
      }
      try {
        _lastSearchTime = DateTime.now();
        final result = await searchSongs(query, source: source);
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  // ===== RAW API CALLS =====
  Future<Map<String, dynamic>> rawSearch(String query, {String source = 'all'}) async {
    return _api.get('/api/music/search', query: {'q': query, 'source': source}, auth: false);
  }

  Future<Map<String, dynamic>> searchSource(String source, String query) async {
    return _api.get('/api/music/search/$source', query: {'q': query}, auth: false);
  }

  Future<Map<String, dynamic>> download(String url, {String source = 'youtube'}) async {
    return _api.get('/api/music/download', query: {'url': url, 'source': source}, auth: false);
  }

  Future<Map<String, dynamic>> prepare(String url, {String source = 'youtube', String? videoId}) async {
    return _api.get('/api/music/prepare', query: {
      'url': url,
      'source': source,
      if (videoId != null) 'videoId': videoId,
    }, auth: false);
  }

  Future<Map<String, dynamic>> getRecommendations() async {
    return _api.get('/api/music/recommendations', auth: false);
  }

  // ===== QUALITY SCORING =====
  int _qualityScore(Song song) {
    int score = 0;

    // Title length & quality
    if (song.title.isNotEmpty) score += 10;
    if (song.title.length > 10) score += 5;

    // Artist quality
    if (song.artist.isNotEmpty && song.artist != 'Unknown Artist') score += 10;

    // Thumbnail
    if (song.thumbnail.isNotEmpty) score += 5;

    // Duration
    final dur = _parseDuration(song.duration);
    if (dur >= 60 && dur <= 600) score += 10;
    else if (dur > 30) score += 5;

    // URL
    if (song.url.isNotEmpty) score += 5;

    // Video ID (unique identifier present)
    if (song.videoId.isNotEmpty) score += 5;

    return score;
  }

  bool _isGoodQuality(Song song) {
    return _qualityScore(song) >= 20;
  }

  int _parseDuration(String duration) {
    if (duration.isEmpty) return 0;
    final parts = duration.split(':');
    if (parts.length == 2) {
      return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
    }
    if (parts.length == 3) {
      return (int.tryParse(parts[0]) ?? 0) * 3600 +
             (int.tryParse(parts[1]) ?? 0) * 60 +
             (int.tryParse(parts[2]) ?? 0);
    }
    return int.tryParse(duration) ?? 0;
  }

  // ===== DEDUPLICATION =====
  List<Song> _deduplicate(List<Song> songs) {
    final seen = <String>{};
    final result = <Song>[];
    for (final song in songs) {
      final key = '${song.source}:${song.videoId}';
      if (key.length > 3 && seen.add(key)) {
        result.add(song);
      }
    }
    return result;
  }

  // ===== CACHE =====
  void _cacheResult(String query, List<Song> songs) {
    if (_searchCache.length >= _maxCacheEntries) {
      _searchCache.remove(_searchCache.keys.first);
    }
    _searchCache[query] = _CacheEntry(songs, DateTime.now());
  }

  // ===== SMART SEARCH WITH PARALLEL FALLBACK =====
  Future<List<Song>> smartSearch(String query) async {
    // Check cache
    final cache = _searchCache[query];
    if (cache != null && !cache.isExpired && cache.songs.isNotEmpty) {
      return cache.songs;
    }

    // Try parallel primary search
    final allSongs = <Song>[];
    try {
      final results = await rawSearch(query, source: 'all').timeout(const Duration(seconds: 8));

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
      }
    } catch (_) {
      // Primary search failed, proceed to fallback
    }

    // If no results, try parallel per-source fallback
    if (allSongs.isEmpty) {
      final fallbackFutures = _searchSources.map((src) async {
        try {
          final res = await searchSource(src, query).timeout(const Duration(seconds: 6));
          if (res['success'] == true) {
            final items = res['results'] as List<dynamic>? ?? [];
            return items
                .map((e) => Song.fromJson(e as Map<String, dynamic>))
                .where(_isGoodQuality)
                .toList();
          }
        } catch (_) {}
        return <Song>[];
      }).toList();

      final fallbackResults = await Future.wait(fallbackFutures);
      for (final songs in fallbackResults) {
        allSongs.addAll(songs);
      }
    }

    // Sort by quality score (descending)
    final uniqueSongs = _deduplicate(allSongs);
    uniqueSongs.sort((a, b) => _qualityScore(b).compareTo(_qualityScore(a)));

    _cacheResult(query, uniqueSongs);
    return uniqueSongs;
  }

  // ===== PUBLIC SEARCH =====
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
