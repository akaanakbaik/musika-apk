import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../config/theme.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = player.queue;
    final current = player.currentSong;

    return Scaffold(
      appBar: AppBar(
        title: Text('Antrian (${q.length})'),
        actions: [
          IconButton(
            icon: Icon(
              player.shuffle ? Icons.shuffle_on : Icons.shuffle,
              color: player.shuffle ? AppTheme.primary : null,
            ),
            tooltip: 'Acak',
            onPressed: player.toggleShuffle,
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            color: player.repeatMode == RepeatMode.none ? null : AppTheme.primary,
            tooltip: 'Ulang: ${_repeatLabel(player.repeatMode)}',
            onPressed: player.cycleRepeatMode,
          ),
          if (q.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Kosongkan Antrian',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Kosongkan Antrian'),
                    content: const Text('Hapus semua lagu dari antrian?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                      TextButton(
                        onPressed: () { player.clearQueue(); Navigator.pop(context); },
                        child: const Text('Kosongkan', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: q.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.queue_music_outlined, size: 32, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  ),
                  const SizedBox(height: 16),
                  Text('Antrian Kosong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
                  const SizedBox(height: 8),
                  Text('Tambahkan lagu ke antrian dari halaman pencarian', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: q.length,
              onReorder: player.reorderQueue,
              itemBuilder: (_, i) {
                final song = q[i];
                final isCurrent = current?.videoId == song.videoId;
                return Container(
                  key: ValueKey('${song.videoId}_$i'),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: isCurrent
                        ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: isCurrent ? AppTheme.primary : (isDark ? Colors.white10 : Colors.black12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.drag_handle, size: 16, color: isCurrent ? Colors.black : Colors.grey[500]),
                      ),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? AppTheme.primary : null,
                      ),
                    ),
                    subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('SEDANG DIPUTAR', style: TextStyle(fontSize: 8, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          ),
                        if (i > 0)
                          IconButton(
                            icon: const Icon(Icons.skip_previous, size: 18),
                            onPressed: () => player.playFromIndex(i, queue: q),
                            tooltip: 'Putar dari sini',
                            color: Colors.grey[500],
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => player.removeFromQueue(i),
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    onTap: () => player.playFromIndex(i, queue: q),
                  ),
                );
              },
            ),
    );
  }

  String _repeatLabel(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none: return 'none';
      case RepeatMode.all: return 'all';
      case RepeatMode.one: return 'one';
    }
  }
}
