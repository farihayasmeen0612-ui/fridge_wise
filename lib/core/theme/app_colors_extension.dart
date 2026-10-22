import 'package:flutter/material.dart';

/// Custom semantic color tokens that extend standard Material 3 ColorScheme.
/// Adheres strictly to the laboratory-clean, zero-emoji design system.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.surfaceElevated,
    required this.cardBorder,
    required this.freshnessSuccess,
    required this.warningAmber,
    required this.dangerRed,
    required this.textSecondary,
    required this.badgeBackgroundTint,
  });

  final Color surfaceElevated;
  final Color cardBorder;
  final Color freshnessSuccess;
  final Color warningAmber;
  final Color dangerRed;
  final Color textSecondary;
  final Color badgeBackgroundTint;

  /// Light theme tokens
  static const AppColorsExtension light = AppColorsExtension(
    surfaceElevated: Color(0xFFF1F5F9), // Soft Light Grey
    cardBorder: Color(0xFFE2E8F0),      // Crisp Light Border
    freshnessSuccess: Color(0xFF059669),// Forest Mint Green
    warningAmber: Color(0xFFD97706),    // Warm Dark Amber
    dangerRed: Color(0xFFDC2626),       // Crimson Red
    textSecondary: Color(0xFF64748B),   // Cool Slate Grey
    badgeBackgroundTint: Color(0x1F0F172A),
  );

  /// Dark theme tokens
  static const AppColorsExtension dark = AppColorsExtension(
    surfaceElevated: Color(0xFF22252C), // Elevated Slate
    cardBorder: Color(0xFF262A33),      // Subtle Slate Border
    freshnessSuccess: Color(0xFF10B981),// Muted Mint Green
    warningAmber: Color(0xFFF59E0B),    // Amber Orange
    dangerRed: Color(0xFFEF4444),       // Coral Red
    textSecondary: Color(0xFF94A3B8),   // Muted Steel Slate
    badgeBackgroundTint: Color(0x26F8FAFC),
  );

  @override
  AppColorsExtension copyWith({
    Color? surfaceElevated,
    Color? cardBorder,
    Color? freshnessSuccess,
    Color? warningAmber,
    Color? dangerRed,
    Color? textSecondary,
    Color? badgeBackgroundTint,
  }) {
    return AppColorsExtension(
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      cardBorder: cardBorder ?? this.cardBorder,
      freshnessSuccess: freshnessSuccess ?? this.freshnessSuccess,
      warningAmber: warningAmber ?? this.warningAmber,
      dangerRed: dangerRed ?? this.dangerRed,
      textSecondary: textSecondary ?? this.textSecondary,
      badgeBackgroundTint: badgeBackgroundTint ?? this.badgeBackgroundTint,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      freshnessSuccess: Color.lerp(freshnessSuccess, other.freshnessSuccess, t)!,
      warningAmber: Color.lerp(warningAmber, other.warningAmber, t)!,
      dangerRed: Color.lerp(dangerRed, other.dangerRed, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      badgeBackgroundTint: Color.lerp(badgeBackgroundTint, other.badgeBackgroundTint, t)!,
    );
  }
}

/// Extension on BuildContext for quick access to semantic colors.
extension AppColorsBuildContextExtension on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}
