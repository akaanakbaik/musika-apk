import 'package:flutter/material.dart';
import '../config/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kebijakan Privasi'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('1. Informasi yang Dikumpulkan',
              'Kami mengumpulkan informasi berikut:\n'
              '• Informasi akun (email, username) saat pendaftaran\n'
              '• Data penggunaan (riwayat putar, favorit, playlist)\n'
              '• Informasi perangkat (tipe, OS, browser)\n'
              '• Alamat IP untuk keamanan'),
          _section('2. Penggunaan Informasi',
              'Informasi Anda digunakan untuk:\n'
              '• Menyediakan dan meningkatkan layanan\n'
              '• Personalisasi pengalaman musik\n'
              '• Mengirim notifikasi penting (verifikasi email, reset password)\n'
              '• Menganalisis penggunaan aplikasi'),
          _section('3. Penyimpanan Data',
              'Data Anda disimpan di server yang aman menggunakan database PostgreSQL (NeonDB). '
              'Kami menggunakan enkripsi untuk melindungi data sensitif seperti password.'),
          _section('4. Berbagai dengan Pihak Ketiga',
              'Kami TIDAK menjual data pribadi Anda ke pihak ketiga. '
              'Kami dapat membagikan data dengan:\n'
              '• Penyedia layanan hosting dan database\n'
              '• Platform musik pihak ketiga untuk pencarian (API publik)\n'
              '• Pihak berwenang jika diwajibkan hukum'),
          _section('5. Hak Anda',
              'Anda berhak untuk:\n'
              '• Mengakses data pribadi Anda\n'
              '• Memperbaiki atau menghapus data\n'
              '• Menarik persetujuan pemrosesan data\n'
              '• Mengekspor data Anda'),
          _section('6. Keamanan',
              'Kami menerapkan langkah keamanan termasuk:\n'
              '• Enkripsi password (bcrypt)\n'
              '• Token JWT untuk autentikasi\n'
              '• Proteksi CSRF dan XSS\n'
              '• Rate limiting pada API'),
          _section('7. Kontak',
              'Untuk pertanyaan tentang privasi, hubungi kami melalui email:\n'
              'musika@akadev.me'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppTheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Privasi Anda adalah prioritas kami. '
                    'Data Anda aman dan tidak akan disalahgunakan.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ),
              ],
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
