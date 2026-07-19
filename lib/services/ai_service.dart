import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_service.dart';

class AiService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> chat(String message) async {
    return await _api.get('/api/ai/chat', query: {'q': message}, auth: false);
  }
}
