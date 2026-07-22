import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/player_provider.dart';
import '../config/theme.dart';
import '../screens/queue_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/lyrics_screen.dart';
import 'sleep_timer.dart';

class QuickSettingsPanel extends StatelessWidget {
  const QuickSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final player = context.watch<PlayerProvider>();
    final timer = context.watch<SleepTimerNotifier>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Pengaturan Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _QuickTile(
                  icon: isDark ? Icons.light_mode : Icons.dark_mode,
                  label: isDark ? 'Terang' : 'Gelap',
                  subtitle: 'Tema',
                  active: true,
                  onTap: () {
                    settings.toggleTheme();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 12),
                _QuickTile(
                  icon: Icons.timer_outlined,
                  label: timer.active ? timer.remainingFormatted : 'Timer',
                  subtitle: 'Tidur',
                  active: timer.active,
                  color: timer.active ? AppTheme.primary : null,
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const SleepTimerSheet(),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _QuickTile(
                  icon: Icons.queue_music_outlined,
                  label: '${player.queueLength}',
                  subtitle: 'Antrian',
                  active: player.queueLength > 0,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const QueueScreen()));
                  },
                ),
                const SizedBox(width: 12),
                _QuickTile(
                  icon: player.shuffle ? Icons.shuffle_on : Icons.shuffle,
                  label: player.shuffle ? 'Nyala' : 'Mati',
                  subtitle: 'Acak',
                  active: player.shuffle,
                  color: player.shuffle ? AppTheme.primary : null,
                  onTap: () {
                    player.toggleShuffle();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _QuickTile(
                  icon: Icons.repeat,
                  label: _repeatLabel(player.repeatMode),
                  subtitle: 'Ulang',
                  active: player.repeatMode != RepeatMode.none,
                  color: player.repeatMode != RepeatMode.none ? AppTheme.primary : null,
                  onTap: () {
                    player.cycleRepeatMode();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 12),
                _QuickTile(
                  icon: player.muted ? Icons.volume_off : Icons.volume_up,
                  label: player.muted ? 'Mati' : '${(player.volume * 100).toInt()}%',
                  subtitle: 'Volume',
                  active: !player.muted,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                _QuickTile(
                  icon: Icons.lyrics_outlined,
                  label: 'Lirik',
                  subtitle: 'Cari',
                  active: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LyricsScreen()));
                  },
                ),
                const SizedBox(width: 12),
                _QuickTile(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  subtitle: 'Akun',
                  active: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _repeatLabel(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none: return 'No';
      case RepeatMode.all: return 'All';
      case RepeatMode.one: return '1';
    }
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool active;
  final Color? color;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon, required this.label, required this.subtitle,
    required this.active, this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? c.withValues(alpha: 0.12) : (Theme.of(context).brightness == Brightness.dark
                ? Colors.white10 : Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: active ? c : Colors.grey[500], size: 24),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? c : Colors.grey[400])),
              Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
