import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/downloads_service.dart';
import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../config/theme.dart';
import 'auth_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final DownloadsService _service = DownloadsService();
  List<Song> _downloads = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _downloads = await _service.getDownloadedSongs();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deleteDownload(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Download'),
        content: const Text('Remove this download from your library?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.deleteDownload(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final player = context.watch<PlayerProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Downloads')),
        body: AuthRequiredWidget(
          onSignIn: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (_downloads.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _load,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(player),
      ),
    );
  }

  Widget _buildBody(PlayerProvider player) {
    if (_loading) return const LoadingWidget(message: 'Loading downloads...');
    if (_error != null) {
      return ServerErrorWidget(error: _error, onRetry: _load);
    }
    if (_downloads.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.download_outlined,
        title: 'No Downloads Yet',
        subtitle: 'Downloaded songs will appear here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _downloads.length,
      itemBuilder: (_, i) {
        final song = _downloads[i];
        return SongTile(
          song: song,
          onTap: () => player.playSong(song, queue: _downloads),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
            onSelected: (value) {
              if (value == 'delete') _deleteDownload(song.videoId);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text('Remove')),
            ],
          ),
        );
      },
    );
  }
}
