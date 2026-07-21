import 'dart:async';
import '../models/song.dart';
import 'api_service.dart';

class DownloadTask {
  final String id;
  final Song song;
  DownloadStatus status;
  double progress;
  String? error;
  final DateTime createdAt;
  Completer<bool>? completer;

  DownloadTask({
    required this.id,
    required this.song,
    this.status = DownloadStatus.pending,
    this.progress = 0.0,
    this.error,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

enum DownloadStatus { pending, downloading, completed, failed }

class DownloadsService {
  final ApiService _api = ApiService();
  final List<DownloadTask> _queue = [];
  bool _isProcessing = false;
  static const int _maxConcurrent = 2;
  final Set<String> _downloadedIds = {};

  // Callback for UI updates
  void Function()? onUpdate;

  List<DownloadTask> get queue => List.unmodifiable(_queue);
  List<DownloadTask> get activeDownloads => _queue.where((t) => t.status == DownloadStatus.downloading).toList();
  List<DownloadTask> get completedDownloads => _queue.where((t) => t.status == DownloadStatus.completed).toList();
  List<DownloadTask> get failedDownloads => _queue.where((t) => t.status == DownloadStatus.failed).toList();
  int get pendingCount => _queue.where((t) => t.status == DownloadStatus.pending).length;
  bool get isProcessing => _isProcessing;

  void _notify() {
    onUpdate?.call();
  }

  Future<Map<String, dynamic>> getDownloads() async {
    return await _api.get('/api/downloads');
  }

  Future<DownloadTask?> addDownload(Song song) async {
    if (_downloadedIds.contains(song.videoId)) return null;

    final task = DownloadTask(
      id: '${song.videoId}_${DateTime.now().millisecondsSinceEpoch}',
      song: song,
    );

    _queue.add(task);
    _downloadedIds.add(song.videoId);
    _notify();

    task.completer = Completer<bool>();
    if (!_isProcessing) {
      unawaited(_processQueue());
    }

    final success = await task.completer!.future;
    return success ? task : null;
  }

  Future<void> _processQueue() async {
    _isProcessing = true;
    _notify();

    while (_queue.any((t) => t.status == DownloadStatus.pending)) {
      final pending = _queue.where((t) => t.status == DownloadStatus.pending).take(_maxConcurrent).toList();
      if (pending.isEmpty) break;
      await Future.wait(pending.map(_processTask));
    }

    _isProcessing = false;
    _notify();
  }

  Future<void> _processTask(DownloadTask task) async {
    task.status = DownloadStatus.downloading;
    task.progress = 0.1;
    _notify();

    try {
      final res = await _api.get('/api/music/download', query: {
        'url': task.song.url,
        'source': task.song.source,
      });

      task.progress = 0.5;
      _notify();

      if (res['success'] == true) {
        await _api.post('/api/downloads', body: {
          'video_id': task.song.videoId,
          'title': task.song.title,
          'artist': task.song.artist,
          'source': task.song.source,
          'url': task.song.url,
          'thumbnail': task.song.thumbnail,
          'duration': task.song.duration,
        });
        task.status = DownloadStatus.completed;
        task.progress = 1.0;
        task.completer?.complete(true);
      } else {
        task.status = DownloadStatus.failed;
        task.error = res['error'] ?? 'Download failed';
        task.completer?.complete(false);
      }
    } catch (e) {
      task.status = DownloadStatus.failed;
      task.error = e.toString();
      task.completer?.complete(false);
    }
    _notify();
  }

  Future<Map<String, dynamic>> addDownloadJson(Map<String, dynamic> songData) async {
    return await _api.post('/api/downloads', body: songData);
  }

  Future<Map<String, dynamic>> deleteDownload(String id) async {
    _queue.removeWhere((t) => t.id == id || t.song.videoId == id);
    _downloadedIds.remove(id);
    _notify();
    return await _api.delete('/api/downloads/$id');
  }

  Future<Map<String, dynamic>> saveSearchQuery(String query, String source) async {
    return await _api.post('/api/search-history', body: {
      'query': query,
      'source': source,
    });
  }

  Future<List<Song>> getDownloadedSongs() async {
    final res = await getDownloads();
    if (res['success'] == true && res['data'] != null) {
      final items = res['data'] as List<dynamic>;
      final songs = items.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
      for (final s in songs) {
        _downloadedIds.add(s.videoId);
      }
      return songs;
    }
    return [];
  }

  void retryFailed() {
    for (final task in _queue.where((t) => t.status == DownloadStatus.failed)) {
      task.status = DownloadStatus.pending;
      task.error = null;
      task.progress = 0.0;
    }
    _notify();
    if (!_isProcessing) {
      unawaited(_processQueue());
    }
  }

  void cancelAll() {
    for (final task in _queue.where((t) => t.status == DownloadStatus.downloading)) {
      task.status = DownloadStatus.failed;
      task.error = 'Cancelled';
      task.completer?.complete(false);
    }
    _notify();
  }

  void clearCompleted() {
    _queue.removeWhere((t) => t.status == DownloadStatus.completed);
    _notify();
  }
}
