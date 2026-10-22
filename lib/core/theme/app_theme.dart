import 'package:flutter/material.dart';
import 'app_colors_extension.dart';

/// Centralized Material 3 Theme Definitions for Light and Dark modes.
/// Adheres strictly to the laboratory-clean, high-contrast, zero-emoji aesthetic.
class AppTheme {
  AppTheme._();

  // --- Light Palette Constants ---
  static const Color _lightScaffoldBg = Color(0xFFF8FAFC);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF2563EB);
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF0F172A);
  static const Color _lightBorder = Color(0xFFE2E8F0);

  // --- Dark Palette Constants ---
  static const Color _darkScaffoldBg = Color(0xFF111215);
  static const Color _darkSurface = Color(0xFF191B20);
  static const Color _darkPrimary = Color(0xFF3B82F6);
  static const Color _darkOnPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextPrimary = Color(0xFFF8FAFC);
  static const Color _darkBorder = Color(0xFF262A33);

  /// Light ThemeData configuration
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      secondary: _lightPrimary,
      onSecondary: _lightOnPrimary,
      error: AppColorsExtension.light.dangerRed,
      onError: Colors.white,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      outline: _lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightScaffoldBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _lightBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightSurface,
        indicatorColor: _lightPrimary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 1,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension.light,
      ],
    );
  }

  /// Dark ThemeData configuration
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      secondary: _darkPrimary,
      onSecondary: _darkOnPrimary,
      error: AppColorsExtension.dark.dangerRed,
      onError: Colors.white,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      outline: _darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkScaffoldBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _darkBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkSurface,
        indicatorColor: _darkPrimary.withValues(alpha: 0.20),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 1,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension.dark,
      ],
    );
  }
}
