import 'api_service.dart';

class AiService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> chat(String message) async {
    return await _api.get('/api/ai/chat', query: {'message': message}, auth: false);
  }
}
