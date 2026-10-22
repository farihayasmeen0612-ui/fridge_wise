import 'package:flutter/material.dart';
import '../../theme/app_colors_extension.dart';

enum AppButtonVariant { primary, secondary, destructive, outlined }

/// Reusable button widget adhering to the kitchen-first ergonomic design system.
/// Features a guaranteed minimum 48dp touch height and clear contrast.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = colorScheme.primary;
        fg = colorScheme.onPrimary;
        break;
      case AppButtonVariant.secondary:
        bg = colors.surfaceElevated;
        fg = colorScheme.onSurface;
        border = BorderSide(color: colors.cardBorder);
        break;
      case AppButtonVariant.destructive:
        bg = colors.dangerContainer;
        fg = colors.dangerRed;
        border = BorderSide(color: colors.dangerBorder);
        break;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = colorScheme.primary;
        border = BorderSide(color: colorScheme.primary);
        break;
    }

    if (!isEnabled) {
      bg = bg.withValues(alpha: 0.5);
      fg = fg.withValues(alpha: 0.5);
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    return SizedBox(
      height: 48,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
