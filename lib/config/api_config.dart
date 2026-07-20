class ApiConfig {
  // Base URL untuk Android emulator (10.0.2.2 = host localhost)
  static const String baseUrl = 'http://10.0.2.2:3001';

  // Production backend URL (Vercel)
  static const String productionUrl = 'https://api-server-flax-xi.vercel.app';

  static const Duration timeout = Duration(seconds: 30);

  static String get apiBase => productionUrl;
}
