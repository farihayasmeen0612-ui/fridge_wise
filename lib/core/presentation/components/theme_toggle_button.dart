import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors_extension.dart';
import '../../theme/theme_notifier.dart';

/// Compact, visually attractive light/dark mode pill toggle.
/// Compatible across Welcome, Login, and Sign-up screens.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({
    super.key,
    this.onGreenHeader = false,
  });

  /// When true, renders against a dark/green header background with tailored contrast.
  final bool onGreenHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final containerBg = onGreenHeader
        ? (isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.18))
        : colors.surfaceElevated;

    final containerBorder = onGreenHeader
        ? Colors.white.withValues(alpha: 0.25)
        : colors.cardBorder;

    final activeIndicatorBg = onGreenHeader
        ? (isDark ? const Color(0xFF1D2821) : const Color(0xFFF4F5ED))
        : colorScheme.surface;

    final activeSunColor = onGreenHeader
        ? (isDark ? const Color(0xFF79C99A) : const Color(0xFF176343))
        : colorScheme.primary;

    final activeMoonColor = onGreenHeader
        ? (isDark ? const Color(0xFF79C99A) : const Color(0xFF176343))
        : colorScheme.primary;

    final inactiveIconColor = onGreenHeader
        ? Colors.white.withValues(alpha: 0.55)
        : colors.textMuted;

    return Semantics(
      button: true,
      label: isDark ? 'Switch to light theme' : 'Switch to dark theme',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(themeNotifierProvider.notifier).setThemeMode(
                  isDark ? ThemeMode.light : ThemeMode.dark,
                );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: containerBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: containerBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Light mode / Sun indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: !isDark ? activeIndicatorBg : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: !isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: onGreenHeader ? 0.15 : 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.light_mode_rounded,
                    size: 16,
                    color: !isDark ? activeSunColor : inactiveIconColor,
                  ),
                ),
                const SizedBox(width: 4),
                // Dark mode / Moon indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark ? activeIndicatorBg : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.dark_mode_rounded,
                    size: 16,
                    color: isDark ? activeMoonColor : inactiveIconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
