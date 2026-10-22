import 'package:flutter/material.dart';
import 'app_colors_extension.dart';

/// Centralized Material 3 Theme Definitions for Light and Dark modes.
/// Follows modern mobile product design principles (clean, readable, zero emojis).
class AppTheme {
  AppTheme._();

  // --- Light Palette Constants ---
  static const Color _lightScaffoldBg = Color(0xFFF9F9F7); // Warm Off-White
  static const Color _lightSurface = Color(0xFFFFFFFF);    // Pure Crisp White
  static const Color _lightPrimary = Color(0xFF1B5E3B);    // Deep Forest Green
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);  // High-contrast white
  static const Color _lightTextPrimary = Color(0xFF181A18);// Near-Black Graphite
  static const Color _lightBorder = Color(0xFFE4E6DE);     // Subtle Warm Border

  // --- Dark Palette Constants ---
  static const Color _darkScaffoldBg = Color(0xFF111311);  // Charcoal Canvas
  static const Color _darkSurface = Color(0xFF191C19);     // Deep Graphite Surface
  static const Color _darkPrimary = Color(0xFF22C55E);     // Mint Forest Accent
  static const Color _darkOnPrimary = Color(0xFF062512);   // Deep Green Text
  static const Color _darkTextPrimary = Color(0xFFF3F5F3); // Crisp Off-White Text
  static const Color _darkBorder = Color(0xFF2B312B);      // Dark Subtle Border

  /// Light ThemeData configuration
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      secondary: AppColorsExtension.light.secondaryAction,
      onSecondary: Colors.white,
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
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsExtension.light.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColorsExtension.light.dangerRed),
        ),
        hintStyle: TextStyle(
          color: AppColorsExtension.light.textMuted,
          fontSize: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightSurface,
        indicatorColor: _lightPrimary.withValues(alpha: 0.12),
        elevation: 1,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _lightPrimary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColorsExtension.light.textSecondary,
          );
        }),
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
      secondary: AppColorsExtension.dark.secondaryAction,
      onSecondary: Colors.white,
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
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsExtension.dark.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColorsExtension.dark.dangerRed),
        ),
        hintStyle: TextStyle(
          color: AppColorsExtension.dark.textMuted,
          fontSize: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkSurface,
        indicatorColor: _darkPrimary.withValues(alpha: 0.20),
        elevation: 1,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _darkPrimary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColorsExtension.dark.textSecondary,
          );
        }),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension.dark,
      ],
    );
  }
}
