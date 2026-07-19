import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/playlist.dart';
import '../config/theme.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;

  const PlaylistTile({
    super.key,
    required this.playlist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: (playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: playlist.coverUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.darkCard),
                  errorWidget: (_, __, ___) => Container(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    child: const Icon(Icons.queue_music, color: AppTheme.primary),
                  ),
                )
              : Container(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.queue_music, color: AppTheme.primary),
                ),
        ),
      ),
      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF121212),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${playlist.songCount} songs${playlist.username != null ? ' · ${playlist.username}' : ''}',
        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
    );
  }
}
