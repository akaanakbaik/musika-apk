import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1DB954);
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF282828);
  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF1DB954);
  static const Color error = Color(0xFFE74C3C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF727272);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: darkSurface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBg,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      hintStyle: const TextStyle(color: textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF333333), thickness: 0.5),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkCard,
      contentTextStyle: TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1DB954),
      secondary: Color(0xFF1DB954),
      surface: lightSurface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF121212)),
      titleTextStyle: TextStyle(
        color: Color(0xFF121212),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: Color(0xFF1DB954),
      unselectedItemColor: Color(0xFF727272),
      type: BottomNavigationBarType.fixed,
      elevation: 2,
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
