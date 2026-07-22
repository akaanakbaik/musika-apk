import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../config/theme.dart';

class ArtistScreen extends StatefulWidget {
  final String artistName;
  const ArtistScreen({super.key, required this.artistName});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  final MusicService _musicService = MusicService();
  List<Song> _songs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchSongs();
  }

  Future<void> _searchSongs() async {
    setState(() { _loading = true; _error = null; });
    try {
      final songs = await _musicService.smartSearch(widget.artistName);
      if (mounted) {
        setState(() {
          _songs = songs.where((s) =>
            s.artist.toLowerCase().contains(widget.artistName.toLowerCase())
          ).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.artistName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${_songs.length} lagu', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Putar Acak',
            onPressed: _songs.isNotEmpty
                ? () => player.playSong(_songs[0], queue: _songs)
                : null,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text('Gagal memuat', style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _searchSongs,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ))
              : _songs.isEmpty
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
                            child: Icon(Icons.person_outline, size: 32, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 16),
                          Text('Tidak ada lagu ditemukan', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _searchSongs,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _songs.length,
                        itemBuilder: (_, i) {
                          final song = _songs[i];
                          return SongTile(
                            song: song,
                            onTap: () => player.playSong(song, queue: _songs),
                          );
                        },
                      ),
                    ),
    );
  }
}
