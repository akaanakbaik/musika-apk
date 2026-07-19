import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/history_service.dart';
import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import 'auth_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _service = HistoryService();
  List<Song> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _service.getHistory();
      if (res['success'] == true && res['history'] != null) {
        final items = res['history'] as List<dynamic>;
        _history = items.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _clear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Clear all listening history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
        ],
      ),
    );
    if (confirm == true) {
      await _service.clearHistory();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final player = context.watch<PlayerProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text('Sign in to see your history', style: TextStyle(color: Colors.grey[400])),
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
        title: const Text('History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clear),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 64, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text('No listening history', style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (_, i) => SongTile(
                      song: _history[i],
                      onTap: () => player.playSong(_history[i], queue: _history),
                    ),
                  ),
      ),
    );
  }
}
