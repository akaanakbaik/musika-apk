import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/player_provider.dart';
import '../config/theme.dart';
import '../utils/formatting.dart';
import '../widgets/source_badge.dart';
import 'package:provider/provider.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;
    if (song == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Minimize',
        ),
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_outlined),
            tooltip: 'Queue',
            onPressed: _showQueue(context, player),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            // Album Art with shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: song.thumbnail.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: song.thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark ? const Color(0xFF282828) : Colors.grey[200],
                            child: const Icon(Icons.music_note, size: 80, color: Colors.white24),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: isDark ? const Color(0xFF282828) : Colors.grey[200],
                            child: const Icon(Icons.music_note, size: 80, color: Colors.white24),
                          ),
                        )
                      : Container(
                          color: isDark ? AppTheme.darkCard : Colors.grey[200],
                          child: const Icon(Icons.music_note, size: 80, color: Colors.white24),
                        ),
                ),
              ),
            ),
            const Spacer(),

            // Song Information
            Text(
              song.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              song.artist,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            if (song.album != null && song.album!.isNotEmpty) ...[                 const SizedBox(height: 4),
              Text(
                song.album!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
            const SizedBox(height: 8),
            SourceBadge(source: song.source, fontSize: 10),
            const Spacer(),

            // Progress Bar
            Row(
              children: [
                Text(
                  formatDuration(player.position),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.primary,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: AppTheme.primary,
                      overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: player.duration > 0
                          ? (player.position / player.duration).clamp(0.0, 1.0)
                          : 0,
                      onChanged: (v) => player.seek(v * player.duration),
                    ),
                  ),
                ),
                Text(
                  formatDuration(player.duration),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Playback Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle, size: 24),
                  onPressed: () => _showToast(context, 'Shuffle'),
                  color: Colors.grey[400],
                  tooltip: 'Shuffle',
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40),
                  onPressed: player.previous,
                  tooltip: 'Previous',
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      player.playing ? Icons.pause : Icons.play_arrow,
                      size: 40,
                      color: Colors.black,
                    ),
                    onPressed: player.togglePlay,
                    tooltip: player.playing ? 'Pause' : 'Play',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40),
                  onPressed: player.next,
                  tooltip: 'Next',
                ),
                IconButton(
                  icon: const Icon(Icons.repeat, size: 24),
                  onPressed: () => _showToast(context, 'Repeat'),
                  color: Colors.grey[400],
                  tooltip: 'Repeat',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Additional Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${player.queue.length} songs in queue',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  VoidCallback _showQueue(BuildContext context, PlayerProvider player) {
    return () {
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (_, scrollController) => Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Up Next',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${player.queue.length} songs',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: player.queue.isEmpty
                    ? Center(
                        child: Text(
                          'Queue is empty',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: player.queue.length,
                        itemBuilder: (_, i) {
                          final qSong = player.queue[i];
                          final isCurrent = i == player.currentIndex;
                          return ListTile(
                            leading: Icon(
                              isCurrent ? Icons.play_arrow : Icons.music_note,
                              color: isCurrent ? AppTheme.primary : Colors.grey,
                              size: 20,
                            ),
                            title: Text(
                              qSong.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isCurrent ? AppTheme.primary : null,
                                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              qSong.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            dense: true,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    };
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
