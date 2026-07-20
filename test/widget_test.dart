import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musika_apk/main.dart';
import 'package:musika_apk/providers/player_provider.dart';
import 'package:musika_apk/providers/auth_provider.dart';
import 'package:musika_apk/providers/settings_provider.dart';
import 'package:musika_apk/screens/home_screen.dart';
import 'package:musika_apk/screens/search_screen.dart';
import 'package:musika_apk/screens/profile_screen.dart';
import 'package:musika_apk/screens/playlists_screen.dart';
import 'package:musika_apk/screens/history_screen.dart';
import 'package:musika_apk/screens/downloads_screen.dart';
import 'package:musika_apk/screens/favorites_screen.dart';
import 'package:musika_apk/screens/ai_chat_screen.dart';
import 'package:musika_apk/config/theme.dart';

Widget createTestApp({bool authenticated = false}) {
  final settings = SettingsProvider();
  final auth = AuthProvider();
  final player = PlayerProvider();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: player),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeScreen(),
    ),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('renders title and greeting', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      expect(find.text('Hi there!'), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('has quick action cards', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      expect(find.text('Search'), findsWidgets);
      expect(find.text('Favorites'), findsWidgets);
      expect(find.text('History'), findsWidgets);
      expect(find.text('AI Chat'), findsWidgets);
    });
  });

  group('SearchScreen', () {
    testWidgets('renders search field', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider.value(
          value: PlayerProvider(),
          child: const SearchScreen(),
        ),
      ));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search songs, artists...'), findsOneWidget);
    });

    testWidgets('shows quick suggestions', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider.value(
          value: PlayerProvider(),
          child: const SearchScreen(),
        ),
      ));
      await tester.pump();

      expect(find.text('Quick Suggestions'), findsOneWidget);
      expect(find.text('Trending'), findsOneWidget);
      expect(find.text('New Releases'), findsOneWidget);
    });
  });

  group('ProfileScreen', () {
    testWidgets('renders sign in prompt for guest', (tester) async {
      final settings = SettingsProvider();
      final auth = AuthProvider();

      await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: auth),
          ],
          child: const ProfileScreen(),
        ),
      ));
      await tester.pump();

      expect(find.text('Please sign-in'), findsOneWidget);
    });
  });

  group('App Theme', () {
    testWidgets('light theme has correct colors', (tester) async {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.primaryColor, AppTheme.primary);
    });

    testWidgets('dark theme has correct colors', (tester) async {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.primaryColor, AppTheme.primary);
    });
  });
}
