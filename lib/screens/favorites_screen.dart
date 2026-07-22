import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_service.dart';
import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../config/theme.dart';
import 'auth_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _service = FavoritesService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<Song> _favorites = [];
  List<Song> _filtered = [];
  bool _loading = true;
  String? _error;
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.from(_favorites);
      } else {
        _filtered = _favorites.where((s) =>
          s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q)
        ).toList();
      }
      _applySort();
    });
  }

  void _applySort() {
    if (_sortBy == 'title') {
      _filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'artist') {
      _filtered.sort((a, b) => a.artist.compareTo(b.artist));
    } else {
      _filtered.sort((a, b) => b.videoId.compareTo(a.videoId));
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _service.getFavorites();
      if (res['success'] == true && res['data'] != null) {
        final items = res['data'] as List<dynamic>;
        _favorites = items.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
        _filtered = List.from(_favorites);
        _applySort();
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _remove(String videoId) async {
    await _service.removeFavorite(videoId);
    _load();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Semua Favorit'),
        content: const Text('Hapus semua lagu dari favorit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus Semua', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      for (final s in _favorites) {
        await _service.removeFavorite(s.videoId);
      }
      _load();
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Urutkan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const Divider(height: 1),
          ListTile(title: const Text('Tanggal Ditambahkan'), trailing: _sortBy == 'date' ? const Icon(Icons.check, color: AppTheme.primary) : null, onTap: () { setState(() => _sortBy = 'date'); _applySort(); Navigator.pop(context); }),
          ListTile(title: const Text('Judul'), trailing: _sortBy == 'title' ? const Icon(Icons.check, color: AppTheme.primary) : null, onTap: () { setState(() => _sortBy = 'title'); _applySort(); Navigator.pop(context); }),
          ListTile(title: const Text('Artis'), trailing: _sortBy == 'artist' ? const Icon(Icons.check, color: AppTheme.primary) : null, onTap: () { setState(() => _sortBy = 'artist'); _applySort(); Navigator.pop(context); }),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final player = context.watch<PlayerProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorit')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text('Masuk untuk melihat favorit', style: TextStyle(color: Colors.grey[400])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                child: const Text('Masuk'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        actions: [
          if (_favorites.isNotEmpty) ...[
            IconButton(icon: const Icon(Icons.sort), onPressed: _showSortOptions, tooltip: 'Sort'),
            IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clearAll, tooltip: 'Clear All'),
          ],
        ],
      ),
      body: Column(
        children: [
          if (_favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Cari favorit...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); })
                      : null,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _buildBody(player),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PlayerProvider player) {
    if (_loading) return const LoadingWidget(message: 'Loading favorites...');
    if (_error != null) {
      return ServerErrorWidget(error: _error, onRetry: _load);
    }
    if (_filtered.isEmpty) {
      if (_searchCtrl.text.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.white24),
              const SizedBox(height: 12),
              Text('No favorites match "${_searchCtrl.text}"', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ],
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text('No favorites yet', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 8),
            Text('Tap the heart icon to add songs', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => SongTile(
        song: _filtered[i],
        onTap: () => player.playSong(_filtered[i], queue: _favorites),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: AppTheme.primary),
          onPressed: () => _remove(_filtered[i].videoId),
        ),
      ),
    );
  }
}
