import 'api_service.dart';

class PlaylistsService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getPlaylists() async {
    return await _api.get('/api/playlists');
  }

  Future<Map<String, dynamic>> getPublicPlaylists(String userId) async {
    return await _api.get('/api/playlists/public/$userId', auth: false);
  }

  Future<Map<String, dynamic>> getPlaylist(String id) async {
    return await _api.get('/api/playlists/$id', auth: false);
  }

  Future<Map<String, dynamic>> createPlaylist(Map<String, dynamic> data) async {
    return await _api.post('/api/playlists', body: data);
  }

  Future<Map<String, dynamic>> updatePlaylist(String id, Map<String, dynamic> data) async {
    return await _api.put('/api/playlists/$id', body: data);
  }

  Future<Map<String, dynamic>> deletePlaylist(String id) async {
    return await _api.delete('/api/playlists/$id');
  }

  Future<Map<String, dynamic>> addSongToPlaylist(String playlistId, Map<String, dynamic> song) async {
    return await _api.post('/api/playlists/$playlistId/songs', body: song);
  }

  Future<Map<String, dynamic>> removeSongFromPlaylist(String playlistId, String songId) async {
    return await _api.delete('/api/playlists/$playlistId/songs/$songId');
  }

  Future<Map<String, dynamic>> copyPlaylist(String id) async {
    return await _api.post('/api/playlists/$id/copy', body: {});
  }
}
