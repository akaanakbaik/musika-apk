import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/history_service.dart';
import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../config/theme.dart';
import 'auth_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _service = HistoryService();
  List<Song> _history = [];
  List<Song> _filtered = [];
  bool _loading = true;
  String? _error;
  String _timeFilter = 'all';

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
      final res = await _service.getHistory();
      if (res['success'] == true && res['data'] != null) {
        final items = res['data'] as List<dynamic>;
        _history = items.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
        _applyFilter();
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _applyFilter() {
    if (_timeFilter == 'all') {
      _filtered = List.from(_history);
      return;
    }
    final now = DateTime.now();
    final cutoff = _timeFilter == 'today'
        ? DateTime(now.year, now.month, now.day)
        : _timeFilter == 'week'
            ? now.subtract(const Duration(days: 7))
            : now.subtract(const Duration(days: 30));
    _filtered = _history.where((s) => true).toList();
  }

  void _setTimeFilter(String filter) {
    setState(() {
      _timeFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _clear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: Text(_timeFilter == 'all' ? 'Clear all listening history?' : 'Clear filtered history?'),
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
          if (_filtered.isNotEmpty)
            IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clear),
        ],
      ),
      body: Column(
        children: [
          // Time filter chips
          if (_history.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(label: 'All Time', selected: _timeFilter == 'all', onTap: () => _setTimeFilter('all')),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Today', selected: _timeFilter == 'today', onTap: () => _setTimeFilter('today')),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'This Week', selected: _timeFilter == 'week', onTap: () => _setTimeFilter('week')),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'This Month', selected: _timeFilter == 'month', onTap: () => _setTimeFilter('month')),
                  ],
                ),
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
    if (_loading) return const LoadingWidget(message: 'Loading history...');
    if (_error != null) {
      return ServerErrorWidget(error: _error, onRetry: _load);
    }
    if (_filtered.isEmpty) {
      if (_history.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history, size: 48, color: Colors.white24),
              const SizedBox(height: 12),
              Text('No listening history for this period', style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text('No listening history', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('${_filtered.length} ${_filtered.length == 1 ? 'song' : 'songs'}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: _filtered.length,
            itemBuilder: (_, i) => SongTile(
              song: _filtered[i],
              onTap: () => player.playSong(_filtered[i], queue: _filtered),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }
}
