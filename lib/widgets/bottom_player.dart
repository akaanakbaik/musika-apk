import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/player_provider.dart';
import '../config/theme.dart';
import '../screens/player_screen.dart';

class BottomPlayer extends StatelessWidget {
  final PlayerProvider player;

  const BottomPlayer({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final song = player.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayerScreen()),
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF282828)
              : Colors.white,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.black12,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 44,
                height: 44,
                child: song.thumbnail.isNotEmpty
                    ? CachedNetworkImage(imageUrl: song.thumbnail, fit: BoxFit.cover)
                    : Container(color: AppTheme.darkCard, child: const Icon(Icons.music_note)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                player.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: AppTheme.primary,
                size: 36,
              ),
              onPressed: player.togglePlay,
            ),
          ],
        ),
      ),
    );
  }
}
