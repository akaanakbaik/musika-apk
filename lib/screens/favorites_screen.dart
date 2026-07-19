import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_service.dart';
import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../config/theme.dart';
import 'auth_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _service = FavoritesService();
  List<Song> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _service.getFavorites();
      if (res['success'] == true && res['favorites'] != null) {
        final items = res['favorites'] as List<dynamic>;
        _favorites = items.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _remove(String videoId) async {
    final res = await _service.removeFavorite(videoId);
    if (res['success'] == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final player = context.watch<PlayerProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text('Sign in to see your favorites', style: TextStyle(color: Colors.grey[400])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _favorites.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (_, i) => SongTile(
                      song: _favorites[i],
                      onTap: () => player.playSong(_favorites[i], queue: _favorites),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: AppTheme.primary),
                        onPressed: () => _remove(_favorites[i].videoId),
                      ),
                    ),
                  ),
      ),
    );
  }
}
