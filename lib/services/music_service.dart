import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/song.dart';
import 'api_service.dart';

class MusicService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> search(String query, {String source = 'all'}) async {
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

  Future<List<Song>> searchSongs(String query, {String source = 'all'}) async {
    final res = await search(query, source: source);
    if (res['success'] != true) return [];
    final results = res['results'] as Map<String, dynamic>? ?? {};
    final songs = <Song>[];
    if (source == 'all') {
      for (final src in ['youtube', 'spotify', 'apple', 'soundcloud']) {
        final items = results[src] as List<dynamic>? ?? [];
        songs.addAll(items.map((e) => Song.fromJson(e as Map<String, dynamic>)));
      }
    } else {
      final items = results[source] as List<dynamic>? ?? [];
      songs.addAll(items.map((e) => Song.fromJson(e as Map<String, dynamic>)));
    }
    return songs;
  }
}
