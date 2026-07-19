import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

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
    }
    return res;
  }

  Future<Map<String, dynamic>> getMe() async {
    return await _api.get('/api/auth/me');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await _api.put('/api/auth/profile', body: data);
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await _api.get('/api/users/$userId', auth: false);
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    return await _api.post('/api/auth/otp/send', body: {'email': email}, auth: false);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    return await _api.post('/api/auth/otp/verify', body: {'email': email, 'code': code}, auth: false);
  }

  Future<User?> getCurrentUser() async {
    final res = await getMe();
    if (res['success'] == true && res['user'] != null) {
      return User.fromJson(res['user']);
    }
    return null;
  }

  Future<void> logout() async {
    await _api.setToken(null);
  }
}
