import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlists_service.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../config/theme.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final PlaylistsService _service = PlaylistsService();
  Playlist? _playlist;
  List<Song> _songs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _service.getPlaylist(widget.playlistId);
      if (res['success'] == true) {
        _playlist = Playlist.fromJson(res['playlist'] as Map<String, dynamic>);
        final songsList = _playlist!.songs ?? res['songs'] as List<dynamic>? ?? [];
        _songs = songsList.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Delete "${_playlist?.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _service.deletePlaylist(widget.playlistId);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _removeSong(String songId) async {
    await _service.removeSongFromPlaylist(widget.playlistId, songId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_playlist?.name ?? 'Playlist'),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: _delete),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.library_music, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text('No songs in this playlist', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (_, i) => SongTile(
                    song: _songs[i],
                    onTap: () => player.playSong(_songs[i], queue: _songs),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => _removeSong(_songs[i].videoId),
                    ),
                  ),
                ),
    );
  }
}
