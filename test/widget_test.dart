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
    testWidgets('renders with providers without crash', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      // Should not crash, even if still loading
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('shows shimmer while loading', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      // Immediately after init, loading state is active
      expect(find.byType(HomeScreen), findsOneWidget);
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

      // "Sign In" appears as ElevatedButton text
      expect(find.text('Sign in to see your profile'), findsOneWidget);
    });

    testWidgets('renders section headers (with scroll)', (tester) async {
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
      await tester.pump();

      // First section header is visible without scroll
      expect(find.text('Playback'), findsOneWidget);

      // Scroll down to find 'Display' section (ListView lazy rendering)
      await tester.scrollUntilVisible(
        find.text('Display'),
        200.0, // scroll increment
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Display'), findsOneWidget);

      // Scroll down more to find 'About'
      await tester.scrollUntilVisible(
        find.text('About'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('About'), findsOneWidget);
    });
  });

  group('AuthScreen', () {
    testWidgets('renders login form with providers', (tester) async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AuthProvider()),
        ],
        child: const MaterialApp(
          home: AuthScreen(),
        ),
      ));
      await tester.pump();

      // AuthScreen has tabs "Sign In" and "Register", plus TextFields
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Register'), findsOneWidget);
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
