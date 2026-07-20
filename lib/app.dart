import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/player_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/playlists_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ai_chat_screen.dart';


class MusikaApp extends StatelessWidget {
  final SettingsProvider settings;

  const MusikaApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musika',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _showSplash = true;

  final _pages = <Widget>[
    const HomeScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
    const PlaylistsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().initialize();
    context.read<SettingsProvider>().initialize();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Container(
        color: const Color(0xFF0a0a0a),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFF141414),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 8)],
                ),
                child: const Icon(Icons.music_note_rounded, size: 48, color: AppTheme.primary),
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'musi', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                    TextSpan(text: 'ka', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Your music, everywhere', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13, letterSpacing: 2)),
              const SizedBox(height: 40),
              SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final player = context.watch<PlayerProvider>();
    final auth = context.watch<AuthProvider>();

    if (!auth.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: IndexedStack(index: _currentIndex, children: _pages)),
          if (player.currentSong != null) const _PlayerBar(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.queue_music_outlined), activeIcon: Icon(Icons.queue_music), label: 'Playlists'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.auto_awesome, color: Colors.black),
      ),
    );
  }
}

class _PlayerBar extends StatelessWidget {
  const _PlayerBar();

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong!;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF282828)
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white10
                : Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Container(
                color: AppTheme.darkCard,
                child: const Icon(Icons.music_note, color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(height: 2),
                Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              player.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: AppTheme.primary,
              size: 36,
            ),
            onPressed: player.togglePlay,
          ),
        ],
      ),
    );
  }
}
