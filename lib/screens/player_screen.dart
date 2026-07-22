import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../config/theme.dart';
import '../utils/formatting.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/source_badge.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showVolume = false;
  bool _showQueue = false;
  bool _liked = false;
  final MusicService _musicService = MusicService();

  Future<void> _downloadSong(Song song) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menyiapkan unduhan...'), behavior: SnackBarBehavior.floating),
    );
    try {
      final res = await _musicService.download(song.url, source: song.source);
      if (res['success'] == true && res['download_url'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link unduhan: ${res['download_url']}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _shareSong(Song song) async {
    final base = 'https://api-server-flax-xi.vercel.app';
    final shareUrl = '$base/share?title=${Uri.encodeComponent(song.title)}&artist=${Uri.encodeComponent(song.artist)}&source=${song.source}&id=${song.videoId}';
    final originalUrl = song.url.isNotEmpty ? song.url : shareUrl;
    final text = 'Dengarkan "${song.title}" oleh ${song.artist} di Musika!\n$originalUrl';
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link lagu disalin ke clipboard!'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {}
  }

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
        ),
        title: const Text('Now Playing', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_liked ? Icons.favorite : Icons.favorite_border, color: _liked ? Colors.redAccent : null),
            onPressed: () => setState(() => _liked = !_liked),
          ),
          IconButton(
            icon: const Icon(Icons.queue_music_outlined),
            onPressed: () => setState(() => _showQueue = !_showQueue),
          ),
        ],
      ),
      body: _showQueue
          ? _buildQueue(player, isDark)
          : _buildPlayer(player, song, isDark),
    );
  }

  Widget _buildPlayer(PlayerProvider player, Song song, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: player.playing ? 0.25 : 0.1),
                  blurRadius: player.playing ? 80 : 40,
                  spreadRadius: player.playing ? 15 : 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: SizedBox(
                width: 320, height: 320,
                child: song.thumbnail.isNotEmpty
                    ? Image.network(song.thumbnail, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _artPlaceholder(isDark))
                    : _artPlaceholder(isDark),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(song.title, textAlign: TextAlign.center, maxLines: 2,
            overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(song.artist, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey[400])),
          if (song.album != null && song.album!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(song.album!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ],
          const SizedBox(height: 8),
          SourceBadge(source: song.source, fontSize: 11),
          const SizedBox(height: 32),

          // Progress
          Row(children: [
            Text(formatDuration(player.position), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SliderTheme(data: SliderThemeData(
                activeTrackColor: AppTheme.primary, inactiveTrackColor: Colors.white24,
                thumbColor: AppTheme.primary, overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ), child: Slider(value: player.duration > 0 ? (player.position / player.duration).clamp(0.0, 1.0) : 0,
                  onChanged: (v) => player.seek(v * player.duration))),
            )),
            Text(formatDuration(player.duration), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ]),
          const SizedBox(height: 24),

          // Controls
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            IconButton(icon: Icon(Icons.shuffle, size: 24, color: player.shuffle ? AppTheme.primary : Colors.grey[400]), onPressed: player.toggleShuffle),
            IconButton(icon: const Icon(Icons.skip_previous, size: 36), onPressed: player.hasPrevious ? player.previous : null, color: player.hasPrevious ? Colors.white : Colors.white24),
            Container(decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)]),
              boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: 2)]),
              child: IconButton(icon: Icon(player.loading ? Icons.hourglass_top : player.playing ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.black),
                  onPressed: player.loading ? null : player.togglePlay)),
            IconButton(icon: const Icon(Icons.skip_next, size: 36), onPressed: player.hasNext ? player.next : null, color: player.hasNext ? Colors.white : Colors.white24),
            IconButton(icon: Icon(player.repeatMode == RepeatMode.one ? Icons.repeat_one : Icons.repeat, size: 24,
                color: player.repeatMode != RepeatMode.none ? AppTheme.primary : Colors.grey[400]), onPressed: player.cycleRepeatMode),
          ]),
          const SizedBox(height: 20),

          // Volume
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: Icon(player.muted ? Icons.volume_off : Icons.volume_up, size: 20, color: Colors.grey[400]), onPressed: player.toggleMute),
            if (_showVolume) SizedBox(width: 120, child: SliderTheme(data: SliderThemeData(
              activeTrackColor: AppTheme.primary, inactiveTrackColor: Colors.white24,
              thumbColor: AppTheme.primary, trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
              child: Slider(value: player.volume, onChanged: player.setVolume)))
            else GestureDetector(onTap: () => setState(() => _showVolume = true),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Text('${(player.volume * 100).toInt()}%', style: TextStyle(fontSize: 12, color: Colors.grey[400])))),
          ]),
          const SizedBox(height: 16),

          // Action buttons
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _actionButton(Icons.download_outlined, 'Download', () => _downloadSong(song)),
            _actionButton(Icons.share_outlined, 'Bagikan', () => _shareSong(song)),
            _actionButton(Icons.add_queue_outlined, 'Antrian', () { player.addToQueue(song); ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ditambahkan ke antrian'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1))); }),
            _actionButton(Icons.lyrics_outlined, 'Lirik', () { }),
          ]),
          const SizedBox(height: 16),

          // Queue Info
          TextButton.icon(onPressed: () => setState(() => _showQueue = !_showQueue),
            icon: const Icon(Icons.queue_music, size: 16),
            label: Text('${player.queueLength} lagu dalam antrian', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            style: TextButton.styleFrom(foregroundColor: Colors.grey)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(
          color: Colors.white10, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.grey[300], size: 22)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildQueue(PlayerProvider player, bool isDark) {
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Antrian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(children: [
            Text('${player.queueLength} lagu', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(width: 12),
            TextButton(onPressed: player.clearQueue, child: const Text('Hapus Semua', style: TextStyle(fontSize: 12, color: Colors.redAccent))),
          ]),
        ])),
      const Divider(height: 1),
      Expanded(child: player.queue.isEmpty
          ? Center(child: Text('Antrian kosong', style: TextStyle(color: Colors.grey[500], fontSize: 15)))
          : ReorderableListView.builder(itemCount: player.queue.length, onReorder: player.reorderQueue,
              itemBuilder: (_, i) {
                final qSong = player.queue[i];
                final isCurrent = i == player.currentIndex && qSong.videoId == player.currentSong?.videoId;
                return Dismissible(key: ValueKey('${qSong.videoId}_$i'), direction: DismissDirection.endToStart,
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.withValues(alpha: 0.3), child: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                  onDismissed: (_) => player.removeFromQueue(i),
                  child: ListTile(key: ValueKey('${qSong.videoId}_$i'),
                    leading: Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                      image: qSong.thumbnail.isNotEmpty ? DecorationImage(image: NetworkImage(qSong.thumbnail), fit: BoxFit.cover) : null,
                      color: isDark ? const Color(0xFF282828) : Colors.grey[200]),
                      child: isCurrent ? Container(decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.play_arrow, color: AppTheme.primary, size: 20)) : null),
                    title: Text(qSong.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isCurrent ? AppTheme.primary : null, fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal, fontSize: 14)),
                    subtitle: Text(qSong.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    trailing: Icon(Icons.drag_handle, color: Colors.grey[600], size: 20),
                    dense: true, onTap: () => player.playFromIndex(i, queue: player.queue)));
              })),
    ]);
  }

  Widget _artPlaceholder(bool isDark) {
    return Container(color: isDark ? const Color(0xFF282828) : Colors.grey[200],
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.music_note, size: 80, color: Colors.white.withValues(alpha: 0.15)),
        const SizedBox(height: 8),
        Text('Musika', style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.1), fontWeight: FontWeight.bold)),
      ]));
  }
}
