import '../models/song.dart';
import 'api_service.dart';

class DownloadsService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getDownloads() async {
    return await _api.get('/api/downloads');
  }

  Future<Map<String, dynamic>> addDownload(Map<String, dynamic> songData) async {
    return await _api.post('/api/downloads', body: songData);
  }

  Future<Map<String, dynamic>> deleteDownload(String id) async {
    return await _api.delete('/api/downloads/$id');
  }

  Future<Map<String, dynamic>> saveSearchQuery(String query, String source) async {
    return await _api.post('/api/search-history', body: {
      'query': query,
      'source': source,
    });
  }

  Future<List<Song>> getDownloadedSongs() async {
    final res = await getDownloads();
    if (res['success'] == true && res['downloads'] != null) {
      final items = res['downloads'] as List<dynamic>;
      return items.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
