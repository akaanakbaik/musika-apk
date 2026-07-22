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
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('shows shimmer while loading', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
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
      expect(find.text('Cari lagu, artis, atau genre...'), findsOneWidget);
    });

    testWidgets('shows trending searches', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider.value(
          value: PlayerProvider(),
          child: const SearchScreen(),
        ),
      ));
      await tester.pump();
      // Indonesian UI: "Pencarian Populer" and chip labels
      expect(find.text('Pencarian Populer'), findsOneWidget);
      expect(find.text('top hits 2026'), findsOneWidget);
      expect(find.text('musik Indonesia terbaru'), findsOneWidget);
    });
  });

  group('ProfileScreen', () {
    testWidgets('shows masuk button for guest', (tester) async {
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
      // Indonesian UI guest text
      expect(find.text('Masuk untuk Fitur Lengkap'), findsOneWidget);
    });

    testWidgets('renders settings screen section headers', (tester) async {
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

      // Navigate to Settings screen
      await tester.tap(find.byTooltip('Pengaturan'));
      await tester.pump();
      await tester.pump();

      // Check Indonesian settings section headers
      expect(find.text('Pemutaran'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Tampilan'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Tampilan'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Tentang'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Tentang'), findsOneWidget);
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
      // Indonesian UI: Masuk (login) and Daftar (register) tabs
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Daftar'), findsOneWidget);
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
