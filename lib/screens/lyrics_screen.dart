import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../config/theme.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _lyrics;
  bool _loading = false;
  String? _error;

  // Sample lyrics database for demonstration
  static const Map<String, String> _sampleLyrics = {
    'love': 'I will always love you\nForever and a day\nNothing can change my feelings\nIn every single way',
    'happy': 'Clap along if you feel like happiness is the truth\nBecause I\'m happy\nClap along if you know what happiness is to you\nBecause I\'m happy',
    'rock': 'We will, we will rock you\nSinging we will, we will rock you\nBuddy you\'re a boy make a big noise\nPlaying in the street gonna be a big man someday',
    'pop': 'You make me feel so good\nDancing through the night\nMusic takes control\nEverything feels right',
  };

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _loadCurrentSong();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadCurrentSong() {
    final player = context.read<PlayerProvider>();
    final song = player.currentSong;
    if (song != null) {
      _searchCtrl.text = song.title;
      _fetchLyrics(song.title);
    }
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() { _lyrics = null; _error = null; });
      return;
    }
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchCtrl.text.trim() == q) _fetchLyrics(q);
    });
  }

  void _fetchLyrics(String query) {
    setState(() { _loading = true; _error = null; _lyrics = null; });
    final lower = query.toLowerCase();
    String? lyrics;
    for (final entry in _sampleLyrics.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        lyrics = entry.value;
        break;
      }
    }
    if (lyrics == null) {
      lyrics = 'Lirik untuk "$query" tidak tersedia.\n\n'
          'Fitur lirik akan segera hadir dengan integrasi database lirik yang lebih lengkap.\n\n'
          'Sementara itu, nikmati musiknya!';
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() { _lyrics = lyrics; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(song != null ? 'Lirik' : 'Cari Lirik'),
        actions: [
          if (song != null)
            IconButton(
              icon: const Icon(Icons.music_note, size: 20),
              tooltip: 'Lagu saat ini',
              onPressed: () {
                _searchCtrl.text = song.title;
                _fetchLyrics(song.title);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari lirik lagu...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => _searchCtrl.clear())
                    : null,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _lyrics == null && _error == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.lyrics_outlined, size: 32, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 16),
                            Text('Cari lirik lagu favoritmu', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                            if (song != null) ...[
                              Text(song.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(song.artist, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                              const SizedBox(height: 24),
                              Container(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                              const SizedBox(height: 24),
                            ],
                            Text(
                              _lyrics ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.8,
                                color: isDark ? Colors.white : const Color(0xFF121212),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
