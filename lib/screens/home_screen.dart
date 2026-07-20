import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart';
import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/source_badge.dart';
import '../config/theme.dart';
import '../utils/constants.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'playlists_screen.dart';
import 'downloads_screen.dart';
import 'ai_chat_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MusicService _musicService = MusicService();
  List<Song> _recommendations = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _musicService.getRecommendations();
      if (res['success'] == true && res['results'] != null) {
        final results = res['results'] as List<dynamic>;
        _recommendations = results
            .map((e) => Song.fromJson(e as Map<String, dynamic>))
            .where((s) => s.title.isNotEmpty && s.videoId.isNotEmpty)
            .toList();
      } else {
        _error = res['error'] ?? 'Failed to load recommendations';
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final player = context.watch<PlayerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'musi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF121212),
                ),
              ),
              const TextSpan(
                text: 'ka',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecommendations,
        child: _loading
            ? const ShimmerList()
            : _error != null
                ? ServerErrorWidget(error: _error, onRetry: _loadRecommendations)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Greeting Section
                      Text(
                        auth.isAuthenticated
                            ? 'Hi, ${auth.user!.displayName ?? auth.user!.username}!'
                            : 'Hi there!',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.welcomeMessage,
                        style: TextStyle(fontSize: 15, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 24),

                      // Quick Action Cards - Row 1
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.search,
                              label: 'Search',
                              subtitle: 'Find music',
                              color: const Color(0xFFE1332D),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SearchScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.favorite,
                              label: 'Favorites',
                              subtitle: 'Your likes',
                              color: const Color(0xFFE91E63),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.queue_music,
                              label: 'Playlists',
                              subtitle: 'Collections',
                              color: const Color(0xFF9C27B0),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PlaylistsScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quick Action Cards - Row 2
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.history,
                              label: 'History',
                              subtitle: 'Recent',
                              color: const Color(0xFF2196F3),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HistoryScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.download_outlined,
                              label: 'Downloads',
                              subtitle: 'Library',
                              color: const Color(0xFF4CAF50),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.auto_awesome,
                              label: 'AI Chat',
                              subtitle: 'Assistant',
                              color: const Color(0xFFFF9800),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AIChatScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Recommendations Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Recommended',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _loadRecommendations,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh'),
                            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Recommendations List
                      if (_recommendations.isEmpty)
                        _buildEmptyRecommendations()
                      else
                        ..._recommendations.map((song) => SongTile(
                          song: song,
                          onTap: () => player.playSong(song, queue: _recommendations),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SourceBadge(source: song.source),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.play_circle_outline, color: AppTheme.primary),
                                onPressed: () => player.playSong(song),
                                tooltip: 'Play',
                              ),
                            ],
                          ),
                        )),
                      const SizedBox(height: 24),

                      // Music Sources Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.library_music, size: 18, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  'Available Sources',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _SourceInfo(
                                  icon: Icons.play_circle_fill,
                                  label: 'YouTube',
                                  color: const Color(0xFFFF0000),
                                  count: '2 APIs',
                                ),
                                _SourceInfo(
                                  icon: Icons.music_note,
                                  label: 'Spotify',
                                  color: AppTheme.primary,
                                  count: '3 APIs',
                                ),
                                _SourceInfo(
                                  icon: Icons.apple,
                                  label: 'Apple Music',
                                  color: const Color(0xFFFC3C44),
                                  count: '4 APIs',
                                ),
                                _SourceInfo(
                                  icon: Icons.cloud,
                                  label: 'SoundCloud',
                                  color: const Color(0xFFFF7700),
                                  count: '2 APIs',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 14, color: AppTheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Search across all platforms at once for the best results',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Auth Section
                      if (auth.isAuthenticated)
                        _buildAuthenticatedSection(auth)
                      else
                        _buildGuestSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyRecommendations() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.music_off, size: 40, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            'No recommendations available',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh or check your connection',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loadRecommendations,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedSection(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
            child: Text(
              (auth.user!.displayName ?? auth.user!.username)[0]
                  .toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signed in',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  auth.user!.displayName ?? auth.user!.username,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                Text(
                  auth.user!.email,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Profile', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sign in for more features',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sync playlists, favorites, and history across devices',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String count;

  const _SourceInfo({
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          count,
          style: TextStyle(fontSize: 9, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
