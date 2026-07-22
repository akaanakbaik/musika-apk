import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../config/theme.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final isDark = settings.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ===== Account Section =====
          if (auth.isAuthenticated) ...[
            _SectionHeader(title: 'Akun'),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: _cardDecor(context),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                        child: Text(
                          (auth.user!.displayName ?? auth.user!.username)[0].toUpperCase(),
                          style: const TextStyle(fontSize: 24, color: AppTheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.user!.displayName ?? auth.user!.username,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.user!.email,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white24),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // ===== Playback Section =====
          _SectionHeader(title: 'Pemutaran'),
          _SettingsCard(
            context: context,
            children: [
              _SwitchTile(
                icon: Icons.blur_on,
                title: 'Crossfade',
                subtitle: 'Transisi mulus antar lagu',
                value: settings.crossfadeEnabled,
                onChanged: (_) => settings.toggleCrossfade(),
              ),
              _DividerLine(),
              _SwitchTile(
                icon: Icons.graphic_eq,
                title: 'Gapless Playback',
                subtitle: 'Tanpa jeda antar lagu',
                value: settings.gaplessPlayback,
                onChanged: (_) => settings.toggleGaplessPlayback(),
              ),
              _DividerLine(),
              _SettingTile(
                icon: Icons.wifi,
                title: 'Kualitas Streaming',
                subtitle: settings.streamingQualityLabel,
                onTap: () => _showPicker(context, settings, 'streaming', [
                  {'key': 'low', 'label': 'Rendah (48 kbps)'},
                  {'key': 'medium', 'label': 'Sedang (128 kbps)'},
                  {'key': 'high', 'label': 'Tinggi (256 kbps)'},
                ], (v) => settings.setStreamingQuality(v)),
              ),
              _DividerLine(),
              _SettingTile(
                icon: Icons.download,
                title: 'Kualitas Download',
                subtitle: settings.audioQualityLabel,
                onTap: () => _showPicker(context, settings, 'audio', [
                  {'key': 'low', 'label': 'Rendah (64 kbps)'},
                  {'key': 'medium', 'label': 'Sedang (128 kbps)'},
                  {'key': 'high', 'label': 'Tinggi (320 kbps)'},
                  {'key': 'auto', 'label': 'Otomatis (rekomendasi)'},
                ], (v) => settings.setAudioQuality(v)),
              ),
              _DividerLine(),
              _SwitchTile(
                icon: Icons.signal_wifi_off,
                title: 'Download via Wi-Fi Saja',
                subtitle: 'Hemat kuota seluler',
                value: settings.downloadOnWifiOnly,
                onChanged: (_) => settings.toggleDownloadOnWifi(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== Display Section =====
          _SectionHeader(title: 'Tampilan'),
          _SettingsCard(
            context: context,
            children: [
              _SwitchTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: 'Mode Gelap',
                subtitle: isDark ? 'Tema gelap aktif' : 'Tema terang aktif',
                value: isDark,
                onChanged: (_) => settings.toggleTheme(),
              ),
              _DividerLine(),
              _SwitchTile(
                icon: Icons.lyrics,
                title: 'Tampilkan Lirik',
                subtitle: 'Lirik sinkron jika tersedia',
                value: settings.showLyrics,
                onChanged: (_) => settings.toggleShowLyrics(),
              ),
              _DividerLine(),
              _SettingTile(
                icon: Icons.language,
                title: 'Bahasa',
                subtitle: settings.language == 'id' ? 'Bahasa Indonesia' : 'English',
                onTap: () => _showLanguagePicker(context, settings),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== Storage Section =====
          _SectionHeader(title: 'Penyimpanan'),
          _SettingsCard(
            context: context,
            children: [
              _SettingTile(
                icon: Icons.storage,
                title: 'Ukuran Cache',
                subtitle: '${settings.maxCacheSize} MB',
                onTap: () => _showCachePicker(context, settings),
              ),
              _DividerLine(),
              ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_sweep, color: Colors.orange, size: 20),
                ),
                title: const Text('Bersihkan Cache', style: TextStyle(fontSize: 14)),
                subtitle: Text('Hapus data sementara', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                onTap: () => _confirmClearCache(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== About Section =====
          _SectionHeader(title: 'Tentang'),
          _SettingsCard(
            context: context,
            children: [
              _AboutTile(
                icon: Icons.info_outline,
                title: 'Musika',
                subtitle: 'Versi ${AppTheme.appVersion}',
              ),
              _DividerLine(),
              _SettingTile(
                icon: Icons.code,
                title: 'Teknologi',
                subtitle: 'Flutter + Bun + NeonDB',
                onTap: () {},
              ),
              _DividerLine(),
              _SettingTile(
                icon: Icons.favorite,
                title: 'Suka aplikasi ini?',
                subtitle: 'Bagikan ke teman!',
                onTap: () => _shareApp(context),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ===== Logout =====
          if (auth.isAuthenticated)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, auth),
                  icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                  label: const Text('Keluar', style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context, SettingsProvider settings, String type, List<Map<String, String>> options, Function(String) onSelect) {
    final current = type == 'streaming' ? settings.streamingQuality : settings.audioQuality;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              type == 'streaming' ? 'Kualitas Streaming' : 'Kualitas Download',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...options.map((opt) => ListTile(
            title: Text(opt['label']!),
            trailing: opt['key'] == current
                ? const Icon(Icons.check_circle, color: AppTheme.primary)
                : null,
            onTap: () {
              onSelect(opt['key']!);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Pilih Bahasa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.check, color: AppTheme.primary),
            title: const Text('Bahasa Indonesia'),
            trailing: settings.language == 'id' ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
            onTap: () { settings.setLanguage('id'); Navigator.pop(context); },
          ),
          ListTile(
            title: const Text('English'),
            trailing: settings.language == 'en' ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
            onTap: () { settings.setLanguage('en'); Navigator.pop(context); },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showCachePicker(BuildContext context, SettingsProvider settings) {
    final sizes = [128, 256, 512, 1024];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Ukuran Cache Maksimal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...sizes.map((s) => ListTile(
            title: Text('$s MB'),
            trailing: settings.maxCacheSize == s ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
            onTap: () { settings.setMaxCacheSize(s); Navigator.pop(context); },
          )),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Bersihkan Cache?'),
        content: const Text('Data sementara akan dihapus. Data penting seperti playlist dan favorit tidak akan terpengaruh.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache dibersihkan'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.black),
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Kamu akan keluar dari akun. Data offline seperti unduhan tetap tersimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              auth.logout();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link dibagikan!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  BoxDecoration _cardDecor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          Container(
            width: 3, height: 16,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[400],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final BuildContext context;
  final List<Widget> children;
  const _SettingsCard({required this.context, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(children: children),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white10
            : Colors.black12,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon, required this.title, required this.subtitle,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon, required this.title, required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _AboutTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary.withValues(alpha: 0.3), AppTheme.primary.withValues(alpha: 0.1)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
