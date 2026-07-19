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
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
              child: Text(
                (auth.user!.displayName ?? auth.user!.username)[0].toUpperCase(),
                style: const TextStyle(fontSize: 36, color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(auth.user!.displayName ?? auth.user!.username,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(auth.user!.email, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            if (auth.user!.bio != null) ...[
              const SizedBox(height: 8),
              Text(auth.user!.bio!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
            ],
            const SizedBox(height: 24),
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
          Text('Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[400])),
          const SizedBox(height: 8),
          // Theme toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'Dark theme active' : 'Light theme active', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            value: isDark,
            onChanged: (_) => settings.toggleTheme(),
            activeColor: AppTheme.primary,
          ),
          // Crossfade toggle
          SwitchListTile(
            title: const Text('Crossfade'),
            subtitle: const Text('Smooth transitions between songs', style: TextStyle(fontSize: 12, color: Colors.white38)),
            value: settings.crossfadeEnabled,
            onChanged: (_) => settings.toggleCrossfade(),
            activeColor: AppTheme.primary,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text('About', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[400])),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white54),
            title: const Text('Musika'),
            subtitle: Text('Version 1.0.1', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
        ],
      ),
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
