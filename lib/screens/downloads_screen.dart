import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../services/downloads_service.dart';
import '../services/music_service.dart';
import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../config/theme.dart';
import 'auth_screen.dart';
import 'player_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final DownloadsService _service = DownloadsService();
  final MusicService _musicService = MusicService();
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _selectedIds = {};
  
  List<_LocalDownload> _downloads = [];
  List<_LocalDownload> _filtered = [];
  bool _loading = true;
  bool _isOffline = false;
  String? _error;
  String _sortBy = 'date';
  bool _isSearching = false;
  bool _selectionMode = false;
  String? _downloadingId;
  double _downloadProgress = 0.0;
  StreamSubscription? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _loadLocalFiles();
    _searchCtrl.addListener(_onSearch);
    _checkConnectivity();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _connectivitySub?.cancel();
    super.dispose();
  }

  void _checkConnectivity() {
    // Check if we can reach the backend
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      final res = await _musicService.getRecommendations().timeout(const Duration(seconds: 3));
      if (mounted && res['success'] == true) {
        setState(() => _isOffline = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.from(_downloads);
        _isSearching = false;
      } else {
        _filtered = _downloads.where((d) =>
          d.song.title.toLowerCase().contains(q) ||
          d.song.artist.toLowerCase().contains(q)
        ).toList();
        _isSearching = true;
      }
      _applySort();
    });
  }

  void _applySort() {
    final list = _isSearching ? _filtered : _downloads;
    if (_sortBy == 'title') {
      list.sort((a, b) => a.song.title.compareTo(b.song.title));
    } else if (_sortBy == 'artist') {
      list.sort((a, b) => a.song.artist.compareTo(b.song.artist));
    } else {
      list.sort((a, b) => b.cachedAt.compareTo(a.cachedAt));
    }
  }

  Future<void> _loadLocalFiles() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dir = await _getDownloadDir();
      if (!await dir.exists()) await dir.create(recursive: true);
      
      final files = await dir.list().toList();
      final entries = <_LocalDownload>[];
      
      for (final f in files) {
        if (f is File && f.path.endsWith('.json')) {
          try {
            final content = await f.readAsString();
            final data = _parseMetaFile(content);
            if (data != null) {
              entries.add(_LocalDownload(
                song: Song.fromJson(data),
                localPath: f.path.replaceAll('.json', '.mp3'),
                cachedAt: await f.lastModified(),
                fileSize: await File(f.path.replaceAll('.json', '.mp3')).length(),
              ));
            }
          } catch (_) {}
        }
      }
      
      entries.sort((a, b) => b.cachedAt.compareTo(a.cachedAt));
      _downloads = entries;
      _filtered = List.from(_downloads);
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Map<String, dynamic>? _parseMetaFile(String content) {
    try {
      final parts = content.split('\n');
      final map = <String, dynamic>{};
      for (final part in parts) {
        if (part.contains(':')) {
          final colonIdx = part.indexOf(':');
          final key = part.substring(0, colonIdx).trim();
          final val = part.substring(colonIdx + 1).trim();
          map[key] = val;
        }
      }
      if (map.isEmpty) return null;
      return {
        'videoId': map['video_id'] ?? map['id'] ?? '',
        'video_id': map['video_id'] ?? map['id'] ?? '',
        'title': map['title'] ?? 'Unknown',
        'artist': map['artist'] ?? 'Unknown Artist',
        'thumbnail': map['thumbnail'] ?? '',
        'duration': map['duration'] ?? '0:00',
        'url': map['url'] ?? '',
        'source': map['source'] ?? 'local',
      };
    } catch (_) {
      return null;
    }
  }

  Future<Directory> _getDownloadDir() async {
    // Try external storage first for true offline access
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      return Directory('/storage/emulated/0/Music/Musika');
    }
    // Fallback to app documents
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/musika_downloads');
  }

  Future<String> _saveLocalFile(Song song, String audioUrl) async {
    final dir = await _getDownloadDir();
    if (!await dir.exists()) await dir.create(recursive: true);
    
    final audioPath = '${dir.path}/${song.videoId}.mp3';
    final metaPath = '${dir.path}/${song.videoId}.json';
    
    // Download audio
    final response = await _musicService.download(audioUrl, source: song.source);
    if (response['success'] == true && response['download_url'] != null) {
      final dlUrl = response['download_url'] as String;
      final httpResp = await HttpClient().getUrl(Uri.parse(dlUrl));
      final httpBody = await httpResp.close();
      final bodyBytes = await httpBody.reduce((a, b) => a + b);
      
      final audioFile = File(audioPath);
      await audioFile.writeAsBytes(bodyBytes);
      
      // Save metadata
      final metaFile = File(metaPath);
      await metaFile.writeAsString(
        'video_id: ${song.videoId}\n'
        'title: ${song.title}\n'
        'artist: ${song.artist}\n'
        'thumbnail: ${song.thumbnail}\n'
        'duration: ${song.duration}\n'
        'url: ${song.url}\n'
        'source: ${song.source}\n'
        'downloaded_at: ${DateTime.now().toIso8601String()}\n'
      );
    }
    
    return audioPath;
  }

  void _playOffline(_LocalDownload dl) {
    Provider.of<PlayerProvider>(context, listen: false).playSong(
      dl.song,
      queue: _downloads.map((d) => d.song).toList(),
    );
  }

  void _shareSong(Song song) {
    final text = '${song.title} - ${song.artist}\nDengarkan di Musika!';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informasi lagu disalin!'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _deleteDownload(int index) async {
    final dl = _downloads[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Unduhan'),
        content: Text('Hapus "${dl.song.title}" dari penyimpanan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final dir = await _getDownloadDir();
        final audioFile = File('${dir.path}/${dl.song.videoId}.mp3');
        final metaFile = File('${dir.path}/${dl.song.videoId}.json');
        if (await audioFile.exists()) await audioFile.delete();
        if (await metaFile.exists()) await metaFile.delete();
        _downloads.removeAt(index);
        _filtered = List.from(_downloads);
        if (mounted) setState(() {});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Dipilih'),
        content: Text('Hapus $count unduhan dari penyimpanan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final dir = await _getDownloadDir();
      for (final vid in _selectedIds) {
        final audioFile = File('${dir.path}/$vid.mp3');
        final metaFile = File('${dir.path}/$vid.json');
        if (await audioFile.exists()) await audioFile.delete();
        if (await metaFile.exists()) await metaFile.delete();
      }
      _downloads.removeWhere((d) => _selectedIds.contains(d.song.videoId));
      _selectedIds.clear();
      _selectionMode = false;
      _filtered = List.from(_downloads);
      if (mounted) setState(() {});
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
          const Padding(padding: EdgeInsets.all(16), child: Text('Urutkan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const Divider(height: 1),
          ListTile(title: const Text('Tanggal'), trailing: _sortBy == 'date' ? const Icon(Icons.check, color: AppTheme.primary) : null, onTap: () { setState(() => _sortBy = 'date'); _applySort(); Navigator.pop(context); }),
          ListTile(title: const Text('Judul'), trailing: _sortBy == 'title' ? const Icon(Icons.check, color: AppTheme.primary) : null, onTap: () { setState(() => _sortBy = 'title'); _applySort(); Navigator.pop(context); }),
          ListTile(title: const Text('Artis'), trailing: _sortBy == 'artist' ? const Icon(Icons.check, color: AppTheme.primary) : null, onTap: () { setState(() => _sortBy = 'artist'); _applySort(); Navigator.pop(context); }),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final player = context.watch<PlayerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayList = _isSearching ? _filtered : _downloads;

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} Dipilih')
            : const Text('Unduhan'),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() { _selectionMode = false; _selectedIds.clear(); }),
              )
            : null,
        actions: [
          if (_isOffline)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 14, color: Colors.orangeAccent),
                  const SizedBox(width: 4),
                  Text('Offline', style: TextStyle(fontSize: 11, color: Colors.orangeAccent)),
                ],
              ),
            ),
          if (!_selectionMode && _downloads.isNotEmpty) ...[
            IconButton(icon: const Icon(Icons.sort), onPressed: _showSortOptions, tooltip: 'Urutkan'),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLocalFiles, tooltip: 'Muat Ulang'),
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () => setState(() => _selectionMode = true),
              tooltip: 'Pilih Banyak',
            ),
          ],
          if (_selectionMode && _selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _deleteSelected,
              tooltip: 'Hapus Dipilih',
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
                  hintText: 'Cari unduhan...',
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
              onRefresh: _loadLocalFiles,
              child: _buildBody(player, displayList, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PlayerProvider player, List<_LocalDownload> songs, bool isDark) {
    if (_loading) return const LoadingWidget(message: 'Memuat unduhan...');
    if (_error != null) return ServerErrorWidget(error: _error!, onRetry: _loadLocalFiles);
    if (songs.isEmpty) {
      if (_isSearching) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.white24),
              const SizedBox(height: 12),
              Text('Tidak ada hasil untuk "${_searchCtrl.text}"', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ],
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.download_outlined, size: 40, color: isDark ? Colors.grey[500] : Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text('Belum Ada Unduhan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 8),
            Text('Download lagu untuk diputar offline', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Cari Lagu'),
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: songs.length,
      itemBuilder: (_, i) {
        final dl = songs[i];
        final song = dl.song;
        final isCurrentlyPlaying = player.currentSong?.videoId == song.videoId;
        return SongTile(
          song: song,
          onTap: _selectionMode
              ? () => _toggleSelection(song.videoId)
              : () {
                  if (dl.localPath.isNotEmpty && File(dl.localPath).existsSync()) {
                    _playOffline(dl);
                  } else {
                    player.playSong(song, queue: songs.map((d) => d.song).toList());
                  }
                },

          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectionMode)
                Checkbox(
                  value: _selectedIds.contains(song.videoId),
                  onChanged: (_) => _toggleSelection(song.videoId),
                  activeColor: AppTheme.primary,
                )
              else
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: isDark ? Colors.white54 : Colors.grey[600], size: 20),
                  onSelected: (value) {
                    if (value == 'play') {
                      player.playSong(song, queue: songs.map((d) => d.song).toList());
                    } else if (value == 'share') {
                      _shareSong(song);
                    } else if (value == 'delete') {
                      _deleteDownload(i);
                    } else if (value == 'select') {
                      _selectionMode = true;
                      _toggleSelection(song.videoId);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'play', child: ListTile(leading: Icon(Icons.play_arrow, size: 18), title: Text('Putar', style: TextStyle(fontSize: 14)))),
                    const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.share, size: 18), title: Text('Bagikan', style: TextStyle(fontSize: 14)))),
                    const PopupMenuItem(value: 'select', child: ListTile(leading: Icon(Icons.checklist, size: 18), title: Text('Pilih', style: TextStyle(fontSize: 14)))),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), title: Text('Hapus', style: TextStyle(fontSize: 14, color: Colors.redAccent)))),
                  ],
                ),
              if (isCurrentlyPlaying)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LocalDownload {
  final Song song;
  final String localPath;
  final DateTime cachedAt;
  final int fileSize;
  _LocalDownload({
    required this.song,
    required this.localPath,
    required this.cachedAt,
    this.fileSize = 0,
  });
}
