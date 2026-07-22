import 'dart:convert';
import 'api_service.dart';

class AiService {
  final ApiService _api = ApiService();
  int _consecutiveFails = 0;
  static const int _maxRetries = 2;
  static const int _maxProviderSwitches = 4;
  int _providerSwitchCount = 0;
  String _currentProvider = 'backend';

  final List<Map<String, String>> _providers = const [
    {'name': 'backend', 'method': 'post', 'endpoint': '/api/ai/chat', 'param': 'message'},
    {'name': 'backend_get', 'method': 'get', 'endpoint': '/api/ai/chat', 'param': 'message'},
    {'name': 'external_cuki', 'method': 'get', 'endpoint': '/api/ai/gemini', 'param': 'prompt'},
    {'name': 'external_prexzy', 'method': 'post', 'endpoint': '/api/ai/copilot', 'param': 'text'},
  ];

  Future<Map<String, dynamic>> chat(String message) async {
    if (_consecutiveFails >= _maxRetries) {
      _switchProvider();
      _consecutiveFails = 0;
    }

    final provider = _providers.firstWhere(
      (p) => p['name'] == _currentProvider,
      orElse: () => _providers[0],
    );

    try {
      Map<String, dynamic> res;

      if (provider['method'] == 'post') {
        if (provider['name'] == 'external_prexzy') {
          res = await _api.post(provider['endpoint']!, body: {'text': message}, auth: false);
        } else {
          res = await _api.post(provider['endpoint']!, body: {'message': message}, auth: false);
        }
      } else {
        res = await _api.get(provider['endpoint']!, query: {provider['param']!: message}, auth: false);
      }

      final reply = res['reply']?.toString() ??
                    res['message']?.toString() ??
                    res['text']?.toString() ??
                    '';

      if (reply.isNotEmpty && reply.length > 5) {
        _consecutiveFails = 0;
        return {'success': true, 'reply': reply};
      }

      _consecutiveFails++;
      return _tryNextFallback(message);
    } catch (e) {
      _consecutiveFails++;
      return _tryNextFallback(message);
    }
  }

  Future<Map<String, dynamic>> _tryNextFallback(String message) async {
    final currentIdx = _providers.indexWhere((p) => p['name'] == _currentProvider);
    if (_providerSwitchCount >= _maxProviderSwitches) {
      _providerSwitchCount = 0;
      return {
        'success': true,
        'reply': 'Maaf, semua layanan AI sedang sibuk. Coba beberapa saat lagi ya!',
      };
    }

    _switchProvider();
    _consecutiveFails = 0;
    return chat(message);
  }

  void _switchProvider() {
    final currentIdx = _providers.indexWhere((p) => p['name'] == _currentProvider);
    final nextIdx = (currentIdx + 1) % _providers.length;
    _currentProvider = _providers[nextIdx]['name']!;
    _providerSwitchCount++;
  }

  void reset() {
    _consecutiveFails = 0;
    _providerSwitchCount = 0;
    _currentProvider = 'backend';
  }
}
