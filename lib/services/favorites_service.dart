import 'api_service.dart';

class FavoritesService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getFavorites() async {
    return await _api.get('/api/favorites');
  }

  Future<Map<String, dynamic>> addFavorite(Map<String, dynamic> song) async {
    return await _api.post('/api/favorites', body: song);
  }

  Future<Map<String, dynamic>> removeFavorite(String videoId) async {
    return await _api.delete('/api/favorites/$videoId');
  }
}
