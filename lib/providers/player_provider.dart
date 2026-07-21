import 'dart:math';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/music_service.dart';

enum RepeatMode { none, one, all }

class PlayerProvider extends ChangeNotifier {
  final MusicService _musicService = MusicService();
  final Random _random = Random();

  Song? _currentSong;
  bool _playing = false;
  bool _loading = false;
  double _position = 0;
  double _duration = 0;
  List<Song> _originalQueue = [];
  List<Song> _shuffledQueue = [];
  int _currentIndex = 0;
  String? _streamUrl;
  RepeatMode _repeatMode = RepeatMode.none;
  bool _shuffle = false;
  final List<String> _playHistory = [];
  static const int _maxHistorySize = 50;
  double _volume = 1.0;
  bool _muted = false;

  Song? get currentSong => _currentSong;
  bool get playing => _playing;
  bool get loading => _loading;
  double get position => _position;
  double get duration => _duration;
  List<Song> get queue => _shuffle ? _shuffledQueue : _originalQueue;
  int get currentIndex => _currentIndex;
  String? get streamUrl => _streamUrl;
  RepeatMode get repeatMode => _repeatMode;
  bool get shuffle => _shuffle;
  double get volume => _muted ? 0 : _volume;
  bool get muted => _muted;
  bool get hasNext => _currentIndex < queue.length - 1 || _repeatMode == RepeatMode.all;
  bool get hasPrevious => _currentIndex > 0 || _repeatMode == RepeatMode.all;
  int get queueLength => queue.length;

  void toggleShuffle() {
    final current = _currentSong;
    _shuffle = !_shuffle;
    if (_shuffle) {
      _shuffledQueue = List.from(_originalQueue);
      if (current != null) {
        _shuffledQueue.remove(current);
        _shuffledQueue.shuffle(_random);
        _shuffledQueue.insert(0, current);
        _currentIndex = 0;
      }
    } else {
      if (current != null) {
        _currentIndex = _originalQueue.indexOf(current);
        if (_currentIndex < 0) _currentIndex = 0;
      }
    }
    notifyListeners();
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
    }
    notifyListeners();
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    if (_volume > 0) _muted = false;
    notifyListeners();
  }

  void toggleMute() {
    _muted = !_muted;
    notifyListeners();
  }

  void _addToHistory(Song song) {
    _playHistory.add(song.videoId);
    if (_playHistory.length > _maxHistorySize) {
      _playHistory.removeAt(0);
    }
  }

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    _currentSong = song;
    _loading = true;
    _position = 0;

    if (queue != null) {
      _originalQueue = queue;
      _shuffledQueue = List.from(queue);
      _currentIndex = queue.indexOf(song);
      if (_currentIndex < 0) _currentIndex = 0;
      if (_shuffle) {
        _shuffledQueue.remove(song);
        _shuffledQueue.shuffle(_random);
        _shuffledQueue.insert(0, song);
        _currentIndex = 0;
      }
    }
    notifyListeners();

    try {
      final res = await _musicService.prepare(song.url, source: song.source, videoId: song.videoId);
      _loading = false;
      if (res['success'] == true) {
        _streamUrl = res['stream_url'] ?? res['url'] ?? res['download_url'];
        _playing = true;
        _addToHistory(song);
      } else {
        _streamUrl = null;
        _playing = false;
      }
    } catch (_) {
      _loading = false;
      _streamUrl = null;
      _playing = false;
    }
    notifyListeners();
  }

  Future<void> playFromIndex(int index, {required List<Song> queue}) async {
    if (index < 0 || index >= queue.length) return;
    await playSong(queue[index], queue: queue);
  }

  void togglePlay() {
    if (_streamUrl != null || _currentSong != null) {
      _playing = !_playing;
      notifyListeners();
    }
  }

  void seek(double position) {
    _position = position.clamp(0.0, _duration);
    notifyListeners();
  }

  Future<void> next() async {
    final current = _currentSong;
    if (_originalQueue.isEmpty) return;

    if (_repeatMode == RepeatMode.one && current != null) {
      await playSong(current, queue: _originalQueue);
      return;
    }

    final q = _shuffle ? _shuffledQueue : _originalQueue;
    if (_currentIndex >= q.length - 1) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = 0;
        await playSong(q[0], queue: _originalQueue);
      }
      return;
    }

    _currentIndex++;
    await playSong(q[_currentIndex], queue: _originalQueue);
  }

  Future<void> previous() async {
    if (_originalQueue.isEmpty) return;

    if (_position > 3) {
      seek(0);
      return;
    }

    final q = _shuffle ? _shuffledQueue : _originalQueue;
    if (_currentIndex <= 0) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = q.length - 1;
        await playSong(q[_currentIndex], queue: _originalQueue);
      }
      return;
    }

    _currentIndex--;
    await playSong(q[_currentIndex], queue: _originalQueue);
  }

  void addToQueue(Song song) {
    _originalQueue.add(song);
    if (_shuffle) {
      _shuffledQueue.insert(_currentIndex + 1, song);
    }
    notifyListeners();
  }

  void removeFromQueue(int index) {
    final current = _currentSong;
    if (index >= 0 && index < _originalQueue.length) {
      _originalQueue.removeAt(index);
      if (_shuffle && current != null) {
        _shuffledQueue = List.from(_originalQueue);
        _shuffledQueue.shuffle(_random);
        _shuffledQueue.remove(current);
        _shuffledQueue.insert(0, current);
        _currentIndex = 0;
      }
      notifyListeners();
    }
  }

  void clearQueue() {
    _originalQueue.clear();
    _shuffledQueue.clear();
    _currentIndex = 0;
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    final current = _currentSong;
    if (oldIndex < newIndex) newIndex--;
    final song = _originalQueue.removeAt(oldIndex);
    _originalQueue.insert(newIndex, song);
    if (_shuffle && current != null) {
      _shuffledQueue = List.from(_originalQueue);
      _shuffledQueue.shuffle(_random);
      _shuffledQueue.remove(current);
      _shuffledQueue.insert(0, current);
      _currentIndex = 0;
    }
    notifyListeners();
  }

  void stop() {
    _currentSong = null;
    _playing = false;
    _streamUrl = null;
    _position = 0;
    _duration = 0;
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
