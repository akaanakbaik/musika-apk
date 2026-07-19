import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlists_service.dart';
import '../models/playlist.dart';
import '../providers/auth_provider.dart';
import '../widgets/playlist_tile.dart';
import '../config/theme.dart';
import 'auth_screen.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final PlaylistsService _service = PlaylistsService();
  List<Playlist> _playlists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _service.getPlaylists();
      if (res['success'] == true && res['playlists'] != null) {
        final items = res['playlists'] as List<dynamic>;
        _playlists = items.map((e) => Playlist.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _create() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Playlist name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await _service.createPlaylist({'name': name});
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Playlists')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.queue_music, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text('Sign in to create playlists', style: TextStyle(color: Colors.grey[400])),
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
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _create),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _playlists.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.queue_music, size: 64, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text('No playlists yet', style: TextStyle(color: Colors.grey[400])),
                        const SizedBox(height: 8),
                        Text('Tap + to create one', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _playlists.length,
                    itemBuilder: (_, i) => PlaylistTile(
                      playlist: _playlists[i],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlistId: _playlists[i].id))),
                    ),
                  ),
      ),
    );
  }
}
