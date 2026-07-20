import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../config/theme.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth.isAuthenticated) ...[
            // User info
            GestureDetector(
              onTap: () => _showEditProfile(context, auth),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      (auth.user!.displayName ?? auth.user!.username)[0].toUpperCase(),
                      style: const TextStyle(fontSize: 36, color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF0a0a0a) : Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showEditProfile(context, auth),
              child: Column(
                children: [
                  Text(auth.user!.displayName ?? auth.user!.username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(auth.user!.email, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                  if (auth.user!.bio != null) ...[
                    const SizedBox(height: 8),
                    Text(auth.user!.bio!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            _MenuItem(icon: Icons.edit_outlined, title: 'Edit Profile', onTap: () => _showEditProfile(context, auth)),
            _MenuItem(icon: Icons.download_outlined, title: 'My Downloads', onTap: () {}),
            const Divider(),
            _MenuItem(icon: Icons.logout, title: 'Sign Out', color: Colors.redAccent, onTap: () {
              auth.logout();
              Navigator.pop(context);
            }),
          ] else ...[
            // Not logged in
            const Center(
              child: Column(
                children: [
                  Icon(Icons.person_outline, size: 80, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('Sign in to see your profile', style: TextStyle(color: Colors.white54)),
                  SizedBox(height: 24),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                child: const Text('Sign In'),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Playback Settings
          _SectionHeader(title: 'Playback'),
          SwitchListTile(
            title: const Text('Crossfade'),
            subtitle: const Text('Smooth transitions between songs', style: TextStyle(fontSize: 12, color: Colors.white38)),
            value: settings.crossfadeEnabled,
            onChanged: (_) => settings.toggleCrossfade(),
            activeColor: AppTheme.primary,
          ),
          SwitchListTile(
            title: const Text('Gapless Playback'),
            subtitle: const Text('No silence between consecutive tracks', style: TextStyle(fontSize: 12, color: Colors.white38)),
            value: settings.gaplessPlayback,
            onChanged: (_) => settings.toggleGaplessPlayback(),
            activeColor: AppTheme.primary,
          ),
          // Streaming Quality
          ListTile(
            leading: const Icon(Icons.wifi, color: Colors.white54),
            title: const Text('Streaming Quality'),
            subtitle: Text(settings.streamingQualityLabel, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            onTap: () => _showQualityPicker(context, settings, 'streaming'),
          ),
          // Download Quality
          ListTile(
            leading: const Icon(Icons.download, color: Colors.white54),
            title: const Text('Download Quality'),
            subtitle: Text(settings.audioQualityLabel, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            onTap: () => _showQualityPicker(context, settings, 'download'),
          ),
          SwitchListTile(
            title: const Text('Download on Wi-Fi Only'),
            subtitle: const Text('Save mobile data', style: TextStyle(fontSize: 12, color: Colors.white38)),
            value: settings.downloadOnWifiOnly,
            onChanged: (_) => settings.toggleDownloadOnWifi(),
            activeColor: AppTheme.primary,
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 16),
          // Display Settings
          _SectionHeader(title: 'Display'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'Dark theme active' : 'Light theme active', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            value: isDark,
            onChanged: (_) => settings.toggleTheme(),
            activeColor: AppTheme.primary,
          ),
          SwitchListTile(
            title: const Text('Show Lyrics'),
            subtitle: const Text('Display synced lyrics when available', style: TextStyle(fontSize: 12, color: Colors.white38)),
            value: settings.showLyrics,
            onChanged: (_) => settings.toggleShowLyrics(),
            activeColor: AppTheme.primary,
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.white54),
            title: const Text('Language'),
            subtitle: Text(_langLabel(settings.language), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            onTap: () => _showLanguagePicker(context, settings),
          ),
          // Cache
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.white54),
            title: const Text('Cache Size'),
            subtitle: Text('${settings.maxCacheSize} MB', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            onTap: () => _showCachePicker(context, settings),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 16),
          // About
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white54),
            title: const Text('Musika'),
            subtitle: Text('Version 1.0.1', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.white38),
            onTap: () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _langLabel(String lang) {
    switch (lang) {
      case 'id': return 'Bahasa Indonesia';
      case 'en': return 'English';
      default: return 'Bahasa Indonesia';
    }
  }

  void _showQualityPicker(BuildContext context, SettingsProvider settings, String type) {
    final options = type == 'streaming'
        ? ['low', 'medium', 'high']
        : ['low', 'medium', 'high', 'auto'];
    final labels = options.map((o) {
      switch (o) {
        case 'low': return 'Low';
        case 'medium': return 'Medium';
        case 'high': return 'High';
        case 'auto': return 'Auto';
        default: return o;
      }
    }).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(type == 'streaming' ? 'Streaming Quality' : 'Download Quality', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...List.generate(options.length, (i) {
            final current = type == 'streaming' ? settings.streamingQuality : settings.audioQuality;
            return ListTile(
              title: Text(labels[i]),
              trailing: options[i] == current ? const Icon(Icons.check, color: AppTheme.primary) : null,
              onTap: () {
                if (type == 'streaming') {
                  settings.setStreamingQuality(options[i]);
                } else {
                  settings.setAudioQuality(options[i]);
                }
                Navigator.pop(context);
              },
            );
          }),
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
            child: Text('Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Bahasa Indonesia'),
            trailing: settings.language == 'id' ? const Icon(Icons.check, color: AppTheme.primary) : null,
            onTap: () { settings.setLanguage('id'); Navigator.pop(context); },
          ),
          ListTile(
            title: const Text('English'),
            trailing: settings.language == 'en' ? const Icon(Icons.check, color: AppTheme.primary) : null,
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
            child: Text('Cache Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...sizes.map((s) => ListTile(
            title: Text('$s MB'),
            trailing: settings.maxCacheSize == s ? const Icon(Icons.check, color: AppTheme.primary) : null,
            onTap: () { settings.setMaxCacheSize(s); Navigator.pop(context); },
          )),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showEditProfile(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.user!.displayName ?? '');
    final bioCtrl = TextEditingController(text: auth.user!.bio ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bioCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save'),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[400])),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.title, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white54),
      title: Text(title, style: TextStyle(color: color ?? Colors.white)),
      onTap: onTap,
    );
  }
}
