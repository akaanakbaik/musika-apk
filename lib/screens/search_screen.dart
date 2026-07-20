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
  List<Song> _results = [];
  bool _loading = false;
  String _selectedSource = 'all';

  final _sources = [
    {'key': 'all', 'label': 'All'},
    {'key': 'youtube', 'label': 'YouTube'},
    {'key': 'spotify', 'label': 'Spotify'},
    {'key': 'apple', 'label': 'Apple Music'},
    {'key': 'soundcloud', 'label': 'SoundCloud'},
  ];

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await _musicService.search(query, source: _selectedSource);
      if (res['success'] == true) {
        final results = res['results'] as Map<String, dynamic>? ?? {};
        final songs = <Song>[];
        if (_selectedSource == 'all') {
          for (final src in ['youtube', 'spotify', 'apple', 'soundcloud']) {
            final items = results[src] as List<dynamic>? ?? [];
            songs.addAll(items.map((e) => Song.fromJson(e as Map<String, dynamic>)));
          }
        } else {
          final items = results[_selectedSource] as List<dynamic>? ?? [];
          songs.addAll(items.map((e) => Song.fromJson(e as Map<String, dynamic>)));
        }
        _results = songs;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs, artists...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchController.clear();
                        setState(() => _results = []);
                      })
                    : null,
              ),
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
            ),
          ),
          // Source filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _sources.map((src) {
                final selected = _selectedSource == src['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(src['label']!),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedSource = src['key']!);
                      if (_searchController.text.isNotEmpty) _search(_searchController.text);
                    },
                    selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                    checkmarkColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.primary : Colors.grey,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: selected ? AppTheme.primary : Colors.white24),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? _buildInitialState()
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (_, i) => SongTile(
                          song: _results[i],
                          onTap: () => player.playSong(_results[i], queue: _results),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_outline, color: AppTheme.primary),
                            onPressed: () => player.playSong(_results[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    final suggestions = [
      {'query': 'top hits 2025', 'icon': Icons.trending_up, 'label': 'Trending'},
      {'query': 'new releases', 'icon': Icons.new_releases, 'label': 'New Releases'},
      {'query': 'Indonesian pop', 'icon': Icons.language, 'label': 'Local Music'},
      {'query': 'chill lo-fi', 'icon': Icons.nightlight_round, 'label': 'Chill Vibes'},
      {'query': 'rock classics', 'icon': Icons.rocket_launch, 'label': 'Rock'},
      {'query': 'jazz piano', 'icon': Icons.piano, 'label': 'Jazz'},
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search, size: 32, color: AppTheme.primary),
                ),
                const SizedBox(height: 16),
                const Text('Search millions of songs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('Find music across YouTube, Spotify, Apple Music, and SoundCloud',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Quick Suggestions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...suggestions.map((s) => ListTile(
            leading: Icon(s['icon'] as IconData, color: Colors.grey[400], size: 22),
            title: Text(s['label'] as String, style: const TextStyle(fontSize: 14)),
            subtitle: Text(s['query'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            trailing: const Icon(Icons.arrow_upward, size: 16, color: Colors.white24),
            onTap: () {
              _searchController.text = s['query'] as String;
              _search(s['query'] as String);
            },
            dense: true,
          )),
          const SizedBox(height: 24),
          const Text('Search Tips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _TipCard(icon: Icons.music_note, text: 'Search by song title, artist, or album'),
          _TipCard(icon: Icons.filter_alt, text: 'Use filters to search a specific source'),
          _TipCard(icon: Icons.auto_awesome, text: 'Try AI Chat for personalized recommendations'),
          _TipCard(icon: Icons.language, text: 'Supports English, Indonesian, and more'),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipCard({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[400]))),
        ],
      ),
    );
  }
}
