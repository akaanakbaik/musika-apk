import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _crossfadeEnabled = true;
  String _audioQuality = 'auto';
  String _language = 'id';
  String _streamingQuality = 'medium';
  int _maxCacheSize = 256;
  bool _downloadOnWifiOnly = true;
  bool _showLyrics = true;
  bool _gaplessPlayback = false;

  ThemeMode get themeMode => _themeMode;
  bool get crossfadeEnabled => _crossfadeEnabled;
  bool get isDark => _themeMode == ThemeMode.dark;
  String get audioQuality => _audioQuality;
  String get language => _language;
  String get streamingQuality => _streamingQuality;
  int get maxCacheSize => _maxCacheSize;
  bool get downloadOnWifiOnly => _downloadOnWifiOnly;
  bool get showLyrics => _showLyrics;
  bool get gaplessPlayback => _gaplessPlayback;

  String get audioQualityLabel {
    switch (_audioQuality) {
      case 'low': return 'Low (64 kbps)';
      case 'medium': return 'Medium (128 kbps)';
      case 'high': return 'High (320 kbps)';
      case 'auto': return 'Auto (recommended)';
      default: return 'Auto';
    }
  }

  String get streamingQualityLabel {
    switch (_streamingQuality) {
      case 'low': return 'Low (48 kbps)';
      case 'medium': return 'Medium (128 kbps)';
      case 'high': return 'High (256 kbps)';
      default: return 'Medium';
    }
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'dark';
    _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;
    _crossfadeEnabled = prefs.getBool('crossfade') ?? true;
    _audioQuality = prefs.getString('audio_quality') ?? 'auto';
    _language = prefs.getString('language') ?? 'id';
    _streamingQuality = prefs.getString('streaming_quality') ?? 'medium';
    _maxCacheSize = prefs.getInt('max_cache_size') ?? 256;
    _downloadOnWifiOnly = prefs.getBool('download_on_wifi') ?? true;
    _showLyrics = prefs.getBool('show_lyrics') ?? true;
    _gaplessPlayback = prefs.getBool('gapless_playback') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleCrossfade() async {
    _crossfadeEnabled = !_crossfadeEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('crossfade', _crossfadeEnabled);
    notifyListeners();
  }

  Future<void> setAudioQuality(String quality) async {
    _audioQuality = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audio_quality', quality);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setStreamingQuality(String quality) async {
    _streamingQuality = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('streaming_quality', quality);
    notifyListeners();
  }

  Future<void> setMaxCacheSize(int size) async {
    _maxCacheSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('max_cache_size', size);
    notifyListeners();
  }

  Future<void> toggleDownloadOnWifi() async {
    _downloadOnWifiOnly = !_downloadOnWifiOnly;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('download_on_wifi', _downloadOnWifiOnly);
    notifyListeners();
  }

  Future<void> toggleShowLyrics() async {
    _showLyrics = !_showLyrics;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_lyrics', _showLyrics);
    notifyListeners();
  }

  Future<void> toggleGaplessPlayback() async {
    _gaplessPlayback = !_gaplessPlayback;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gapless_playback', _gaplessPlayback);
    notifyListeners();
  }
}
