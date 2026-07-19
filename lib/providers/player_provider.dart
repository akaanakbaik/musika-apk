import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/music_service.dart';

class PlayerProvider extends ChangeNotifier {
  final MusicService _musicService = MusicService();
  
  Song? _currentSong;
  bool _playing = false;
  bool _loading = false;
  double _position = 0;
  double _duration = 0;
  List<Song> _queue = [];
  int _currentIndex = 0;
  String? _streamUrl;

  Song? get currentSong => _currentSong;
  bool get playing => _playing;
  bool get loading => _loading;
  double get position => _position;
  double get duration => _duration;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  String? get streamUrl => _streamUrl;

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    _currentSong = song;
    _loading = true;
    if (queue != null) {
      _queue = queue;
      _currentIndex = queue.indexOf(song);
    }
    notifyListeners();

    try {
      final res = await _musicService.prepare(song.url, source: song.source, videoId: song.videoId);
      if (res['success'] == true) {
        _streamUrl = res['stream_url'];
        _playing = true;
      }
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  void togglePlay() {
    _playing = !_playing;
    notifyListeners();
  }

  void seek(double position) {
    _position = position;
    notifyListeners();
  }

  void next() {
    if (_queue.isEmpty || _currentIndex >= _queue.length - 1) return;
    _currentIndex++;
    playSong(_queue[_currentIndex]);
  }

  void previous() {
    if (_queue.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex--;
      playSong(_queue[_currentIndex]);
    }
  }

  void stop() {
    _currentSong = null;
    _playing = false;
    _streamUrl = null;
    _position = 0;
    notifyListeners();
  }

  void setDuration(double dur) {
    _duration = dur;
    notifyListeners();
  }

  void setPosition(double pos) {
    _position = pos;
    notifyListeners();
  }
}
