import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Musika';
  static const String appVersion = '1.0.1';
  static const String appDescription = 'Your music, everywhere';
  static const String appTagline = 'Stream, discover, and enjoy music from multiple sources';
  static const String welcomeMessage = 'What do you want to listen to?';

  // API Configuration
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(seconds: 60);
  static const int maxRetries = 3;
  static const int maxSearchResults = 50;

  // Cache durations
  static const Duration searchCacheDuration = Duration(minutes: 10);
  static const Duration playlistCacheDuration = Duration(minutes: 5);
  static const Duration recommendationsCacheDuration = Duration(minutes: 30);

  // Player
  static const double defaultVolume = 0.8;
  static const double seekStepSeconds = 10;
  static const int crossfadeDurationMs = 3000;
  static const double maxPlaybackSpeed = 2.0;
  static const double minPlaybackSpeed = 0.5;

  // UI Constants
  static const double cardBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double thumbnailSize = 48.0;
  static const double largeThumbnailSize = 56.0;
  static const double playerHeight = 64.0;
  static const double bottomNavHeight = 60.0;
  static const double headerHeight = 56.0;
  static const double fabSize = 56.0;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(milliseconds: 2500);

  // Feature Flags
  static const bool enableCrossfade = true;
  static const bool enableNotifications = true;
  static const bool enableBackgroundPlayback = true;
  static const bool enableGaplessPlayback = true;

  // Error Messages
  static const String errorNetwork = 'No internet connection. Please check your network.';
  static const String errorServer = 'Server is not responding. Please try again later.';
  static const String errorAuth = 'Session expired. Please sign in again.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorUnknown = 'Something went wrong. Please try again.';
  static const String errorEmptyQuery = 'Please enter a search query.';
  static const String errorNoResults = 'No results found. Try a different search.';

  // Placeholder URLs
  static const String defaultAvatar = 'https://raw.githubusercontent.com/akaanakbaik/my-cdn/main/musika/default-avatar.png';
  static const String appLogo = 'https://raw.githubusercontent.com/akaanakbaik/my-cdn/main/musika/logonobglatar121212.png';

  // Source Labels
  static const Map<String, String> sourceLabels = {
    'youtube': 'YouTube',
    'spotify': 'Spotify',
    'apple': 'Apple Music',
    'soundcloud': 'SoundCloud',
  };

  // Source Colors
  static const Map<String, Color> sourceColors = {
    'youtube': Color(0xFFFF0000),
    'spotify': Color(0xFF1DB954),
    'apple': Color(0xFFFC3C44),
    'soundcloud': Color(0xFFFF7700),
  };

  // Genre categories for recommendations
  static const List<String> genreQueries = [
    'top hits 2025 Indonesia',
    'viral songs 2025',
    'Billboard Hot 100',
    'trending music now',
    'best pop 2025',
    'lagu hits Indonesia',
    'k-pop hits 2025',
    'lo-fi beats chill',
    'top spotify 2025',
    'best r&b soul 2025',
    'rock classics',
    'electronic dance music',
    'jazz relaxation',
    'hip hop 2025',
    'acoustic covers',
  ];
}
