import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musika_apk/providers/player_provider.dart';
import 'package:musika_apk/providers/auth_provider.dart';
import 'package:musika_apk/providers/settings_provider.dart';
import 'package:musika_apk/screens/home_screen.dart';
import 'package:musika_apk/screens/search_screen.dart';
import 'package:musika_apk/screens/profile_screen.dart';
import 'package:musika_apk/screens/auth_screen.dart';
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
    testWidgets('renders greeting for guest', (tester) async {
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
    testWidgets('shows sign in button for guest', (tester) async {
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

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders section headers', (tester) async {
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

      expect(find.text('Playback'), findsOneWidget);
      expect(find.text('Display'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });
  });

  group('AuthScreen', () {
    testWidgets('renders login form', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const AuthScreen(),
      ));
      await tester.pump();

      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('AppTheme', () {
    testWidgets('light theme has correct brightness', (tester) async {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('dark theme has correct brightness', (tester) async {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });
  });
}
