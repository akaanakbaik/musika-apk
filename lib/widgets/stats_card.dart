import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate stats from play history
    final historyCount = player.playHistoryLength;
    final queueCount = player.queueLength;
    final hasCurrent = player.currentSong != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_outlined, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Statistik Mendengarkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(
                icon: Icons.music_note,
                value: '${historyCount}',
                label: 'Lagu Diputar',
                color: AppTheme.primary,
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.queue_music,
                value: '$queueCount',
                label: 'Dalam Antrian',
                color: const Color(0xFF9C27B0),
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.favorite,
                value: '0',
                label: 'Favorit',
                color: const Color(0xFFE91E63),
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.access_time,
                value: hasCurrent ? player.currentSong!.duration : '0:00',
                label: 'Lagu Saat Ini',
                color: const Color(0xFFFF9800),
                isDark: isDark,
              ),
            ],
          ),
          if (auth.isAuthenticated) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tips', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                        const SizedBox(height: 2),
                        Text(
                          'Semakin sering kamu mendengarkan, semakin baik rekomendasi musik yang kamu dapatkan!',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.icon, required this.value, required this.label,
    required this.color, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
