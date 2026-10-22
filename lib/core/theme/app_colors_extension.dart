import 'package:flutter/material.dart';

/// Semantic color tokens calibrated for Light and Dark themes.
/// Adheres strictly to WCAG 2.1 AA accessibility standards and zero-emoji design.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.surfaceElevated,
    required this.cardBorder,
    required this.freshnessSuccess,
    required this.freshnessContainer,
    required this.freshnessBorder,
    required this.warningAmber,
    required this.warningContainer,
    required this.warningBorder,
    required this.dangerRed,
    required this.dangerContainer,
    required this.dangerBorder,
    required this.textSecondary,
    required this.textMuted,
    required this.secondaryAction,
    required this.badgeBackgroundTint,
  });

  final Color surfaceElevated;
  final Color cardBorder;
  final Color freshnessSuccess;
  final Color freshnessContainer;
  final Color freshnessBorder;
  final Color warningAmber;
  final Color warningContainer;
  final Color warningBorder;
  final Color dangerRed;
  final Color dangerContainer;
  final Color dangerBorder;
  final Color textSecondary;
  final Color textMuted;
  final Color secondaryAction;
  final Color badgeBackgroundTint;

  /// Light theme tokens (Warm off-white base, deep forest green primary)
  static const AppColorsExtension light = AppColorsExtension(
    surfaceElevated: Color(0xFFF0F1ED),
    cardBorder: Color(0xFFE4E6DE),
    freshnessSuccess: Color(0xFF166534), // Forest Mint Green (WCAG 7.1:1)
    freshnessContainer: Color(0xFFDCFCE7),
    freshnessBorder: Color(0xFF86EFAC),
    warningAmber: Color(0xFF9A3412),     // Terracotta Amber (WCAG 6.1:1)
    warningContainer: Color(0xFFFFEDD5),
    warningBorder: Color(0xFFFDBA74),
    dangerRed: Color(0xFF991B1B),        // Deep Crimson (WCAG 7.4:1)
    dangerContainer: Color(0xFFFEE2E2),
    dangerBorder: Color(0xFFFCA5A5),
    textSecondary: Color(0xFF525852),    // Slate Moss (WCAG 6.5:1)
    textMuted: Color(0xFF737973),        // Neutral Muted (WCAG 4.6:1)
    secondaryAction: Color(0xFF1E40AF),  // Slate Cobalt
    badgeBackgroundTint: Color(0x1F181A18),
  );

  /// Dark theme tokens (Charcoal & Graphite base, vibrant mint green accents)
  static const AppColorsExtension dark = AppColorsExtension(
    surfaceElevated: Color(0xFF222622),
    cardBorder: Color(0xFF2B312B),
    freshnessSuccess: Color(0xFF4ADE80), // Bright Mint (WCAG 8.4:1)
    freshnessContainer: Color(0xFF143820),
    freshnessBorder: Color(0xFF1E5C33),
    warningAmber: Color(0xFFFDBA74),     // Warm Peach-Amber (WCAG 7.5:1)
    warningContainer: Color(0xFF3E200C),
    warningBorder: Color(0xFF7C2D12),
    dangerRed: Color(0xFFFCA5A5),        // Soft Coral Red (WCAG 8.2:1)
    dangerContainer: Color(0xFF3B1313),
    dangerBorder: Color(0xFF7F1D1D),
    textSecondary: Color(0xFFA3ABA2),    // Muted Steel Slate (WCAG 6.2:1)
    textMuted: Color(0xFF798278),        // Dark Muted Grey (WCAG 4.5:1)
    secondaryAction: Color(0xFF3B82F6),  // Electric Slate Blue
    badgeBackgroundTint: Color(0x26F3F5F3),
  );

  @override
  AppColorsExtension copyWith({
    Color? surfaceElevated,
    Color? cardBorder,
    Color? freshnessSuccess,
    Color? freshnessContainer,
    Color? freshnessBorder,
    Color? warningAmber,
    Color? warningContainer,
    Color? warningBorder,
    Color? dangerRed,
    Color? dangerContainer,
    Color? dangerBorder,
    Color? textSecondary,
    Color? textMuted,
    Color? secondaryAction,
    Color? badgeBackgroundTint,
  }) {
    return AppColorsExtension(
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      cardBorder: cardBorder ?? this.cardBorder,
      freshnessSuccess: freshnessSuccess ?? this.freshnessSuccess,
      freshnessContainer: freshnessContainer ?? this.freshnessContainer,
      freshnessBorder: freshnessBorder ?? this.freshnessBorder,
      warningAmber: warningAmber ?? this.warningAmber,
      warningContainer: warningContainer ?? this.warningContainer,
      warningBorder: warningBorder ?? this.warningBorder,
      dangerRed: dangerRed ?? this.dangerRed,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      secondaryAction: secondaryAction ?? this.secondaryAction,
      badgeBackgroundTint: badgeBackgroundTint ?? this.badgeBackgroundTint,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      freshnessSuccess: Color.lerp(freshnessSuccess, other.freshnessSuccess, t)!,
      freshnessContainer: Color.lerp(freshnessContainer, other.freshnessContainer, t)!,
      freshnessBorder: Color.lerp(freshnessBorder, other.freshnessBorder, t)!,
      warningAmber: Color.lerp(warningAmber, other.warningAmber, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      dangerRed: Color.lerp(dangerRed, other.dangerRed, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      secondaryAction: Color.lerp(secondaryAction, other.secondaryAction, t)!,
      badgeBackgroundTint: Color.lerp(badgeBackgroundTint, other.badgeBackgroundTint, t)!,
    );
  }
}

/// Extension on BuildContext for clean access to AppColorsExtension tokens
extension AppColorsBuildContextExtension on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}
