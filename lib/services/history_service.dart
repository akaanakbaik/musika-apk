import 'api_service.dart';

class HistoryService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getHistory() async {
    return await _api.get('/api/history');
  }

  Future<Map<String, dynamic>> addHistory(Map<String, dynamic> entry) async {
    return await _api.post('/api/history', body: entry);
  }

  Future<Map<String, dynamic>> clearHistory() async {
    return await _api.delete('/api/history');
  }
}
