import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _crossfadeEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get crossfadeEnabled => _crossfadeEnabled;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'dark';
    _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;
    _crossfadeEnabled = prefs.getBool('crossfade') ?? true;
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
}
