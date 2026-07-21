import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'musika_token_v3';

  final List<String> _baseUrls = ApiConfig.allUrls;
  int _currentUrlIndex = 0;
  String? _token;
  int _consecutiveFails = 0;
  static const int _maxRetries = 2;
  static const int _fallbackThreshold = 3;

  String get _baseUrl => _baseUrls[_currentUrlIndex];
  int get currentUrlIndex => _currentUrlIndex;
  int get totalUrls => _baseUrls.length;

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

  void setUrlIndex(int index) {
    if (index >= 0 && index < _baseUrls.length) {
      _currentUrlIndex = index;
      _consecutiveFails = 0;
    }
  }

  void _tryFallback() {
    _consecutiveFails++;
    if (_consecutiveFails >= _fallbackThreshold) {
      _currentUrlIndex = (_currentUrlIndex + 1) % _baseUrls.length;
      _consecutiveFails = 0;
    }
  }

  void _resetFailures() {
    _consecutiveFails = 0;
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client': 'musika-app/1.0',
    };
    if (auth) {
      final t = await token;
      if (t != null) headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  Future<Duration> _backoff(int attempt) async {
    final delay = Duration(milliseconds: min(2000, 200 * pow(2, attempt).toInt()));
    await Future.delayed(delay);
    return delay;
  }

  Future<Map<String, dynamic>> _executeRequest(
    Future<http.Response> Function(String url, Map<String, String> headers) requestFactory,
    String path, {
    bool auth = true,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final maxAttempts = _baseUrls.length * (_maxRetries + 1);
    Map<String, dynamic>? lastError;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final urlIndex = _currentUrlIndex;
      final baseUrl = _baseUrls[urlIndex];
      final headers = await _headers(auth: auth);

      try {
        var uri = Uri.parse('$baseUrl$path');
        if (query != null && query.isNotEmpty) {
          uri = uri.replace(queryParameters: query);
        }

        http.Response response;
        if (body != null) {
          response = await requestFactory(uri.toString(), headers)
              .timeout(ApiConfig.timeout);
        } else {
          response = await requestFactory(uri.toString(), headers)
              .timeout(ApiConfig.timeout);
        }

        if (response.statusCode == 429) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        if (response.body.isEmpty) {
          lastError = {'success': false, 'error': 'Empty response'};
          _tryFallback();
          continue;
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (response.statusCode >= 400) {
          lastError = {
            'success': false,
            'error': data['error'] ?? 'Request failed (${response.statusCode})',
            'code': response.statusCode,
          };
          if (response.statusCode >= 500) {
            _tryFallback();
            continue;
          }
          _resetFailures();
          return lastError!;
        }

        _resetFailures();
        return data;
      } on SocketException {
        lastError = {'success': false, 'error': 'No internet connection', 'retryable': true};
        _tryFallback();
        await _backoff(attempt);
      } on http.ClientException {
        lastError = {'success': false, 'error': 'Connection failed', 'retryable': true};
        _tryFallback();
        await _backoff(attempt);
      } on FormatException {
        lastError = {'success': false, 'error': 'Invalid response format'};
        _tryFallback();
      } on TimeoutException {
        lastError = {'success': false, 'error': 'Request timed out', 'retryable': true};
        _tryFallback();
        await _backoff(attempt);
      } catch (e) {
        lastError = {'success': false, 'error': 'Unexpected error: ${e.toString().substring(0, e.toString().length > 80 ? 80 : e.toString().length)}', 'retryable': true};
        _tryFallback();
        await _backoff(attempt);
      }
    }

    return lastError ?? {'success': false, 'error': 'All endpoints failed'};
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = true, Map<String, String>? query}) async {
    return _executeRequest(
      (url, headers) => http.get(Uri.parse(url), headers: headers),
      path,
      auth: auth,
      query: query,
    );
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    return _executeRequest(
      (url, headers) => http.post(Uri.parse(url), headers: headers, body: body != null ? jsonEncode(body) : null),
      path,
      auth: auth,
      body: body,
    );
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    return _executeRequest(
      (url, headers) => http.put(Uri.parse(url), headers: headers, body: body != null ? jsonEncode(body) : null),
      path,
      auth: auth,
      body: body,
    );
  }

  Future<Map<String, dynamic>> delete(String path, {bool auth = true}) async {
    return _executeRequest(
      (url, headers) => http.delete(Uri.parse(url), headers: headers),
      path,
      auth: auth,
    );
  }
}
