import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../config/theme.dart';

class ShareSongSheet extends StatelessWidget {
  final Song song;
  const ShareSongSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shareUrl = '${song.url.isNotEmpty ? song.url : ""}';
    final shareText = '${song.title} - ${song.artist}\n\nDengarkan di Musika!\n$shareUrl';
    final appUrl = 'https://github.com/akaanakbaik/musika-apk';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48, height: 48,
                  color: isDark ? Colors.white10 : Colors.black12,
                  child: const Icon(Icons.music_note, color: AppTheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(song.artist, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ).padding(const EdgeInsets.symmetric(horizontal: 24)),
          const SizedBox(height: 20),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.copy, color: AppTheme.primary, size: 18),
            ),
            title: const Text('Salin Info Lagu', style: TextStyle(fontSize: 15)),
            subtitle: const Text('Judul, artis, dan link', style: TextStyle(fontSize: 11)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: shareText));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Info lagu disalin!'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.link, color: Colors.green, size: 18),
            ),
            title: const Text('Salin Link', style: TextStyle(fontSize: 15)),
            subtitle: Text(song.url.isNotEmpty ? song.url : 'Link tidak tersedia', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            onTap: () {
              if (song.url.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: song.url));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link disalin!'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating),
                );
              }
            },
          ),
          ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.share, color: Colors.blue, size: 18),
            ),
            title: const Text('Bagikan Aplikasi', style: TextStyle(fontSize: 15)),
            subtitle: const Text('Rekomendasikan Musika ke teman', style: TextStyle(fontSize: 11)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: appUrl));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link Musika disalin!'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ],
      ),
    );
  }
}

extension EdgeInsetsPadding on Widget {
  Widget padding(EdgeInsetsGeometry padding) => Padding(padding: padding, child: this);
}
