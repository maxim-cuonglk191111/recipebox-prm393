import 'package:flutter/material.dart';

/// One place for colours, spacing and type scale. Warm paper + ink, 1px borders.
class Palette {
  static const paper = Color(0xFFF6F1E7);
  static const surface = Color(0xFFFFFCF5);
  static const ink = Color(0xFF1F1B16);
  static const inkSoft = Color(0xFF4A433A);
  static const accent = Color(0xFF2D4A3A);
  static const border = Color(0xFF8C8272);
  static const error = Color(0xFF9B2226);
  static const success = Color(0xFF2D4A3A);
  static const star = Color(0xFFB7791F);
}

class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}

OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: c, width: w),
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: Palette.accent, brightness: Brightness.light).copyWith(
    primary: Palette.accent,
    onPrimary: Colors.white,
    surface: Palette.surface,
    onSurface: Palette.ink,
    error: Palette.error,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.paper,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Palette.ink, height: 1.2),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Palette.ink),
      bodyMedium: TextStyle(fontSize: 14, color: Palette.ink, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, color: Palette.inkSoft, height: 1.4),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.paper,
      foregroundColor: Palette.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Palette.ink),
      shape: Border(bottom: BorderSide(color: Palette.border)),
    ),
    cardTheme: CardThemeData(
      color: Palette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Palette.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: _border(Palette.border),
      enabledBorder: _border(Palette.border),
      focusedBorder: _border(Palette.accent, 2),
      errorBorder: _border(Palette.error),
      focusedErrorBorder: _border(Palette.error, 2),
      errorStyle: const TextStyle(color: Palette.error, fontSize: 12),
      errorMaxLines: 3,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.ink,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: Palette.ink),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Palette.accent, minimumSize: const Size(48, 48)),
    ),
    dividerTheme: const DividerThemeData(color: Palette.border, thickness: 1, space: 1),
  );
}
