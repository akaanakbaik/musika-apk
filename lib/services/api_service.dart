import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'musika_token_v3';

  final String _baseUrl = ApiConfig.apiBase;
  String? _token;

  Future<String?> get token async {
    _token ??= await _storage.read(key: _tokenKey);
    return _token;
  }

  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final t = await token;
      if (t != null) headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = true, Map<String, String>? query}) async {
    try {
      var uri = Uri.parse('$_baseUrl$path');
      if (query != null) uri = uri.replace(queryParameters: query);
      final response = await http.get(uri, headers: await _headers(auth: auth))
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'No internet connection'};
    } on http.ClientException {
      return {'success': false, 'error': 'Connection failed'};
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'No internet connection'};
    }
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'No internet connection'};
    }
  }

  Future<Map<String, dynamic>> delete(String path, {bool auth = true}) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(auth: auth),
      ).timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'No internet connection'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      return {'success': false, 'error': data['error'] ?? 'Request failed (${response.statusCode})'};
    }
    return data;
  }
}
