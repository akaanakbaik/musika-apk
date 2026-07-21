import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  User? _cachedUser;
  int _otpResendCooldown = 0;

  User? get cachedUser => _cachedUser;
  int get otpResendCooldown => _otpResendCooldown;

  void clearCache() {
    _cachedUser = null;
  }

  Future<Map<String, dynamic>> register(String email, String password, String username) async {
    final res = await _api.post('/api/auth/register', body: {
      'email': email,
      'password': password,
      'username': username,
    }, auth: false);
    if (res['success'] == true && res['token'] != null) {
      await _api.setToken(res['token']);
    }
    return res;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    }, auth: false);
    if (res['success'] == true && res['token'] != null) {
      await _api.setToken(res['token']);
      _cachedUser = res['user'] != null ? User.fromJson(res['user']) : null;
    }
    return res;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _api.get('/api/auth/me');
    if (res['success'] == true && res['user'] != null) {
      _cachedUser = User.fromJson(res['user']);
    }
    return res;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await _api.put('/api/auth/profile', body: data);
    if (res['success'] == true && res['user'] != null) {
      _cachedUser = User.fromJson(res['user']);
    }
    return res;
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await _api.get('/api/users/$userId', auth: false);
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    if (_otpResendCooldown > 0) {
      return {'success': false, 'error': 'Please wait ${_otpResendCooldown}s before resending'};
    }
    final res = await _api.post('/api/auth/otp/send', body: {'email': email}, auth: false);
    if (res['success'] == true) {
      _otpResendCooldown = 60;
      _startCooldownTimer();
    }
    return res;
  }

  void _startCooldownTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_otpResendCooldown <= 0) return false;
      _otpResendCooldown--;
      return _otpResendCooldown > 0;
    });
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final res = await _api.post('/api/auth/otp/verify', body: {
      'email': email,
      'code': code,
    }, auth: false);
    if (res['success'] == true && res['token'] != null) {
      await _api.setToken(res['token']);
      _otpResendCooldown = 0;
    }
    return res;
  }

  Future<User?> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser;
    await getMe();
    return _cachedUser;
  }

  Future<void> logout() async {
    await _api.setToken(null);
    _cachedUser = null;
  }
}
