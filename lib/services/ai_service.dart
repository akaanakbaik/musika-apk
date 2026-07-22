import 'api_service.dart';

class AiService {
  final ApiService _api = ApiService();
  int _consecutiveFails = 0;
  static const int _maxRetries = 3;
  String _currentProvider = 'prexzy';
  final List<String> _providers = ['prexzy', 'gemini'];

  Future<Map<String, dynamic>> chat(String message) async {
    if (_consecutiveFails >= _maxRetries) {
      _switchProvider();
      _consecutiveFails = 0;
    }

    if (_currentProvider == 'prexzy') {
      final res = await _api.post('/api/ai/chat', body: {
        'message': message,
      }, auth: false);

      if (res['success'] == true) {
        _consecutiveFails = 0;
        return res;
      }

      _consecutiveFails++;
      final fallbackRes = await _api.get('/api/ai/gemini', query: {
        'prompt': message,
      }, auth: false);

      if (fallbackRes['success'] == true) {
        _consecutiveFails = 0;
        _currentProvider = 'gemini';
        return fallbackRes;
      }

      _consecutiveFails++;
      // Direct GET to /api/ai/chat as final fallback
      try {
        final getRes = await _api.get('/api/ai/chat', query: {'message': message}, auth: false);
        if (getRes['success'] == true) {
          _consecutiveFails = 0;
          return getRes;
        }
      } catch (_) {}
      return res;
    } else {
      final res = await _api.get('/api/ai/chat', query: {
        'message': message,
      }, auth: false);

      if (res['success'] == true) {
        _consecutiveFails = 0;
        return res;
      }

      _consecutiveFails++;
      final fallbackRes = await _api.post('/api/ai/chat', body: {
        'message': message,
      }, auth: false);

      _consecutiveFails = 0;
      _currentProvider = 'prexzy';
      return fallbackRes;
    }
  }

  void _switchProvider() {
    final idx = _providers.indexOf(_currentProvider);
    _currentProvider = _providers[(idx + 1) % _providers.length];
  }

  void resetFailures() {
    _consecutiveFails = 0;
  }
}
