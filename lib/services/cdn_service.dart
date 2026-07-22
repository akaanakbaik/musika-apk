import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CdnService {
  static const int _maxSize = 5 * 1024 * 1024;
  static const int _maxRetries = 3;

  static const List<Map<String, String>> _providers = [
    {'url': 'https://cdn.izukaprivate.my.id/upload', 'name': 'izuka'},
    {'url': 'https://cdn.nekohime.site/upload', 'name': 'nekohime'},
  ];

  int _providerIndex = 0;

  Future<String> uploadImage(File imageFile, {String prefix = 'avatar'}) async {
    if (!await imageFile.exists()) {
      throw Exception('File tidak ditemukan');
    }

    final bytes = await imageFile.readAsBytes();
    if (bytes.length > _maxSize) {
      throw Exception('File terlalu besar: ${(bytes.length / 1024 / 1024).toStringAsFixed(1)}MB (maks 5MB)');
    }

    final ext = imageFile.path.split('.').last;
    final filename = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    for (int attempt = 0; attempt < _providers.length * _maxRetries; attempt++) {
      final provider = _providers[_providerIndex % _providers.length];
      final tries = attempt % _maxRetries;
      final isLastAttempt = attempt >= _providers.length * _maxRetries - 1;

      try {
        final uri = Uri.parse(provider['url']!);
        final request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath('file', imageFile.path, filename: filename));

        final client = http.Client();
        final streamedResponse = await client.send(request).timeout(const Duration(seconds: 120));
        final response = await http.Response.fromStream(streamedResponse);
        client.close();
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (response.statusCode == 200 && data['url'] != null) {
          final fn = data['url'].toString().split('/').last;
          return 'https://cdn.izukaprivate.my.id/cdn/$fn';
        }

        if (data['files'] != null) {
          final files = data['files'];
          if (files is List && files.isNotEmpty) {
            return files[0]['url']?.toString() ?? files[0].toString();
          }
          if (files is Map && files['url'] != null) {
            return files['url'].toString();
          }
        }

        if (isLastAttempt) throw Exception(data['error'] ?? 'Upload gagal');
      } on SocketException {
        if (isLastAttempt) rethrow;
      } catch (e) {
        if (isLastAttempt) rethrow;
      }

      _providerIndex++;
      await Future.delayed(Duration(seconds: tries + 1));
    }

    throw Exception('Semua provider CDN gagal');
  }

  void resetProvider() {
    _providerIndex = 0;
  }
}
