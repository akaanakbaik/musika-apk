import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../config/theme.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool dense;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.trailing,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(dense ? 6 : 8),
        child: SizedBox(
          width: dense ? 40 : 48,
          height: dense ? 40 : 48,
          child: song.thumbnail.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: song.thumbnail,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.darkCard),
                  errorWidget: (_, __, ___) => Container(
                    color: AppTheme.darkCard,
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
                )
              : Container(
                  color: AppTheme.darkCard,
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF121212),
          fontWeight: FontWeight.w500,
          fontSize: dense ? 13 : 14,
        ),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              song.source.toUpperCase(),
              style: const TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
            ),
          ),
        ],
      ),
      trailing: trailing,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 2 : 4),
    );
  }
}
