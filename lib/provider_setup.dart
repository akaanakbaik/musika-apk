import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/player_provider.dart';
import 'providers/settings_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/music_service.dart';
import 'services/favorites_service.dart';
import 'services/history_service.dart';
import 'services/playlists_service.dart';
import 'services/ai_service.dart';
import 'widgets/sleep_timer.dart';

class MultiProviderSetup extends StatelessWidget {
  final Widget child;

  const MultiProviderSetup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SleepTimerNotifier()),
        // Services as providers for dependency injection
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => MusicService()),
        Provider(create: (_) => FavoritesService()),
        Provider(create: (_) => HistoryService()),
        Provider(create: (_) => PlaylistsService()),
        Provider(create: (_) => AiService()),
      ],
      child: child,
    );
  }
}
