import 'package:flutter/material.dart';
import '../config/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Syarat & Ketentuan'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('1. Penerimaan Syarat',
              'Dengan menggunakan aplikasi Musika, Anda menyetujui syarat dan ketentuan ini. '
              'Jika Anda tidak setuju, jangan gunakan aplikasi ini.'),
          _section('2. Layanan',
              'Musika adalah aplikasi pemutar musik yang menyediakan akses ke konten dari '
              'berbagai sumber pihak ketiga (YouTube, Spotify, Apple Music, SoundCloud). '
              'Kami tidak menyimpan konten secara permanen dan tidak bertanggung jawab atas '
              'konten yang disediakan oleh pihak ketiga.'),
          _section('3. Akun Pengguna',
              'Anda bertanggung jawab menjaga kerahasiaan akun dan password. '
              'Semua aktivitas yang terjadi di akun Anda adalah tanggung jawab Anda.'),
          _section('4. Penggunaan yang Diizinkan',
              'Anda setuju untuk tidak:\n'
              '• Menyalahgunakan layanan untuk tujuan ilegal\n'
              '• Mendistribusikan ulang konten tanpa izin\n'
              '• Mengakses atau memodifikasi sistem tanpa izin'),
          _section('5. Hak Kekayaan Intelektual',
              'Nama, logo, dan desain Musika adalah milik kami. '
              'Konten dari platform pihak ketiga tetap menjadi milik pemiliknya masing-masing.'),
          _section('6. Batasan Tanggung Jawab',
              'Musika tidak bertanggung jawab atas kerusakan langsung atau tidak langsung '
              'yang timbul dari penggunaan atau ketidakmampuan menggunakan layanan ini.'),
          _section('7. Perubahan Syarat',
              'Kami dapat mengubah syarat ini sewaktu-waktu. '
              'Perubahan akan diumumkan melalui aplikasi.'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Terakhir diperbarui: Juli 2026',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[400], height: 1.6)),
        ],
      ),
    );
  }
}
