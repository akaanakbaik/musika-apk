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
  final TextEditingController _searchCtrl = TextEditingController();
  List<Song> _downloads = [];
  List<Song> _filtered = [];
  bool _loading = true;
  String? _error;
  String _sortBy = 'date';
  bool _isSearching = false;
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

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
        _filtered = List.from(_downloads);
        _isSearching = false;
      } else {
        _filtered = _downloads.where((s) =>
          s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q)
        ).toList();
        _isSearching = true;
      }
      _applySort();
    });
  }

  void _applySort() {
    final list = _isSearching ? _filtered : _downloads;
    if (_sortBy == 'title') {
      list.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'artist') {
      list.sort((a, b) => a.artist.compareTo(b.artist));
    }
    if (!_isSearching) _downloads = list;
    else _filtered = list;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _downloads = await _service.getDownloadedSongs();
      _filtered = List.from(_downloads);
      _applySort();
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

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Selected'),
        content: Text('Remove $count selected downloads?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove All', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      for (final id in _selectedIds) {
        await _service.deleteDownload(id);
      }
      _selectedIds.clear();
      _selectionMode = false;
      _load();
    }
  }

  void _toggleSelection(String videoId) {
    setState(() {
      if (_selectedIds.contains(videoId)) {
        _selectedIds.remove(videoId);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(videoId);
      }
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const Divider(height: 1),
          ListTile(title: const Text('Date Added'), trailing: _sortBy == 'date' ? const Icon(Icons.check, color: AppTheme.primary) : null, onTap: () { setState(() => _sortBy = 'date'); _applySort(); Navigator.pop(context); }),
          ListTile(title: const Text('Title'), trailing: _sortBy == 'title' ? const Icon(Icons.check, color: AppTheme.primary) : null, onTap: () { setState(() => _sortBy = 'title'); _applySort(); Navigator.pop(context); }),
          ListTile(title: const Text('Artist'), trailing: _sortBy == 'artist' ? const Icon(Icons.check, color: AppTheme.primary) : null, onTap: () { setState(() => _sortBy = 'artist'); _applySort(); Navigator.pop(context); }),
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
        appBar: AppBar(title: const Text('Downloads')),
        body: AuthRequiredWidget(
          onSignIn: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
        ),
      );
    }

    final displayList = _isSearching ? _filtered : _downloads;

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} Selected')
            : const Text('Downloads'),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() { _selectionMode = false; _selectedIds.clear(); }),
              )
            : null,
        actions: [
          if (!_selectionMode && _downloads.isNotEmpty) ...[
            IconButton(icon: const Icon(Icons.sort), onPressed: _showSortOptions, tooltip: 'Sort'),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'Refresh'),
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () => setState(() => _selectionMode = true),
              tooltip: 'Select Multiple',
            ),
          ],
          if (_selectionMode && _selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _deleteSelected,
              tooltip: 'Remove Selected',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_downloads.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search downloads...',
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
              child: _buildBody(player, displayList),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PlayerProvider player, List<Song> songs) {
    if (_loading) return const LoadingWidget(message: 'Loading downloads...');
    if (_error != null) {
      return ServerErrorWidget(error: _error, onRetry: _load);
    }
    if (songs.isEmpty) {
      if (_isSearching) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.white24),
              const SizedBox(height: 12),
              Text('No downloads match "${_searchCtrl.text}"', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ],
          ),
        );
      }
      return const EmptyStateWidget(
        icon: Icons.download_outlined,
        title: 'No Downloads Yet',
        subtitle: 'Downloaded songs will appear here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: songs.length,
      itemBuilder: (_, i) {
        final song = songs[i];
        return SongTile(
          song: song,
          onTap: _selectionMode
              ? () => _toggleSelection(song.videoId)
              : () => player.playSong(song, queue: _downloads),
          trailing: _selectionMode
              ? null
              : PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                  onSelected: (value) {
                    if (value == 'delete') _deleteDownload(song.videoId);
                    if (value == 'select') {
                      _selectionMode = true;
                      _toggleSelection(song.videoId);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'play', child: ListTile(leading: Icon(Icons.play_arrow, size: 18), title: Text('Play', style: TextStyle(fontSize: 14)))),
                    const PopupMenuItem(value: 'select', child: ListTile(leading: Icon(Icons.checklist, size: 18), title: Text('Select', style: TextStyle(fontSize: 14)))),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), title: Text('Remove', style: TextStyle(fontSize: 14, color: Colors.redAccent)))),
                  ],
                ),
        );
      },
    );
  }
}
