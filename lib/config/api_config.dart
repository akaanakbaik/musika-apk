class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3001';
  static const String productionUrl = 'https://api-server-flax-xi.vercel.app';
  static const String backupUrl = 'https://api-server-flax-xi.vercel.app';

  static const Duration timeout = Duration(seconds: 30);

  static String get apiBase => productionUrl;

  static List<String> get allUrls => [
    productionUrl,
    baseUrl,
    backupUrl,
  ];
}
