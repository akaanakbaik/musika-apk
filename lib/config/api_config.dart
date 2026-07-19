class ApiConfig {
  // Change this to your deployed backend URL
  static const String baseUrl = 'http://10.0.2.2:3001'; // Android emulator localhost

  // Will be updated after Vercel deployment
  static const String productionUrl = 'https://musika-api.vercel.app';

  static const Duration timeout = Duration(seconds: 30);

  static String get apiBase => baseUrl;
}
