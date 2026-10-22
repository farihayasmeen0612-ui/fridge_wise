import 'package:flutter/material.dart';
import '../../../features/inventory/domain/models/expiry_status.dart';
import '../../theme/app_colors_extension.dart';

/// Semantic pill badge communicating expiry urgency with high contrast and zero emojis.
class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    required this.status,
    required this.label,
    super.key,
  });

  final ExpiryStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Color fg;
    Color bg;
    Color border;
    IconData icon;

    switch (status) {
      case ExpiryStatus.fresh:
        fg = colors.freshnessSuccess;
        bg = colors.freshnessContainer;
        border = colors.freshnessBorder;
        icon = Icons.check_circle_outline_rounded;
        break;
      case ExpiryStatus.expiringSoon:
        fg = colors.warningAmber;
        bg = colors.warningContainer;
        border = colors.warningBorder;
        icon = Icons.schedule_rounded;
        break;
      case ExpiryStatus.expired:
        fg = colors.dangerRed;
        bg = colors.dangerContainer;
        border = colors.dangerBorder;
        icon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
