import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../config/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MusicService _musicService = MusicService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Song> _results = [];
  bool _loading = false;
  String? _error;
  String _selectedSource = 'all';
  Timer? _debounce;

  final _sources = [
    {'key': 'all', 'label': 'Semua', 'icon': Icons.all_inclusive},
    {'key': 'youtube', 'label': 'YouTube', 'icon': Icons.play_circle_fill},
    {'key': 'spotify', 'label': 'Spotify', 'icon': Icons.music_note},
    {'key': 'apple', 'label': 'Apple', 'icon': Icons.apple},
    {'key': 'soundcloud', 'label': 'SoundCloud', 'icon': Icons.cloud},
  ];

  final _trendingSearches = [
    {'query': 'top hits 2026', 'label': 'Trending', 'icon': Icons.trending_up},
    {'query': 'musik Indonesia terbaru', 'label': 'Lokal', 'icon': Icons.language},
    {'query': 'chill lo-fi', 'label': 'Relaksasi', 'icon': Icons.nightlight_round},
    {'query': 'rock klasik', 'label': 'Klasik', 'icon': Icons.rocket_launch},
    {'query': 'K-Pop hits', 'label': 'K-Pop', 'icon': Icons.auto_awesome},
    {'query': 'jazz santai', 'label': 'Jazz', 'icon': Icons.piano},
  ];

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) { _search(query); }
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      final songs = await _musicService.searchSongs(query, source: _selectedSource);
      if (mounted) setState(() {
        _results = songs;
        _loading = false;
        if (songs.isEmpty) _error = 'Tidak ada hasil untuk "$query"';
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = 'Terjadi kesalahan. Coba lagi.'; });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Musik'), centerTitle: true),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Cari lagu, artis, atau genre...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.search, size: 22),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _searchFocus.unfocus();
                          setState(() { _results = []; _error = null; });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF282828) : const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
            ),
          ),

          // Source Filters
          Container(
            height: 48,
            margin: const EdgeInsets.only(bottom: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _sources.length,
              itemBuilder: (_, i) {
                final src = _sources[i];
                final selected = _selectedSource == src['key'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    avatar: Icon(src['icon'] as IconData, size: 16,
                      color: selected ? AppTheme.primary : Colors.grey),
                    label: Text(src['label'] as String, style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    )),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedSource = src['key'] as String);
                      if (_searchController.text.trim().isNotEmpty) {
                        _search(_searchController.text);
                      }
                    },
                    selectedColor: AppTheme.primary.withValues(alpha: 0.25),
                    checkmarkColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.primary : Colors.grey,
                    ),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                      color: selected ? AppTheme.primary : Colors.white24,
                      width: selected ? 1.5 : 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                );
              },
            ),
          ),

          // Results
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _results.isEmpty
                    ? _buildErrorState()
                    : _results.isNotEmpty
                        ? _buildResults(player)
                        : _buildInitialState(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(PlayerProvider player) {
    return RefreshIndicator(
      onRefresh: () => _search(_searchController.text),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _results.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text('${_results.length} hasil', style: TextStyle(
                    fontSize: 12, color: Colors.grey[500])),
                  const Spacer(),
                  Text(_selectedSource == 'all' ? 'Semua sumber' : _selectedSource,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            );
          }
          final idx = i - 1;
          return SongTile(
            song: _results[idx],
            onTap: () => player.playSong(_results[idx], queue: _results),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_circle_outline, color: AppTheme.primary, size: 28),
                  onPressed: () => player.playSong(_results[idx]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Welcome
          Center(
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withValues(alpha: 0.2), AppTheme.primary.withValues(alpha: 0.05)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search, size: 36, color: AppTheme.primary),
                ),
                const SizedBox(height: 16),
                const Text('Cari Jutaan Lagu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'YouTube, Spotify, Apple Music, SoundCloud',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Trending Searches
          Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Pencarian Populer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingSearches.map((s) => ActionChip(
              avatar: Icon(s['icon'] as IconData, size: 16, color: AppTheme.primary),
              label: Text(s['query'] as String, style: const TextStyle(fontSize: 12)),
              onPressed: () {
                _searchController.text = s['query'] as String;
                _search(s['query'] as String);
              },
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
            )).toList(),
          ),

          const SizedBox(height: 32),

          // Tips
          Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Tips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          _TipTile(icon: Icons.filter_alt, text: 'Gunakan filter sumber untuk hasil spesifik'),
          _TipTile(icon: Icons.auto_awesome, text: 'Tanya AI Chat untuk rekomendasi personal'),
          _TipTile(icon: Icons.language, text: 'Cari dalam Bahasa Indonesia atau Inggris'),
          _TipTile(icon: Icons.timer, text: 'Hasil akan muncul otomatis saat kamu mengetik'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_error?.contains('hasil') == true
                ? Icons.search_off : Icons.wifi_off,
              size: 32, color: Colors.orange),
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Tidak ada hasil',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _search(_searchController.text),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Coba Lagi'),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[400]))),
        ],
      ),
    );
  }
}
