import 'package:flutter/material.dart';
import '../../theme/app_colors_extension.dart';

/// 3-column unified KPI metric bar inspired by high-utility athletic/workout apps.
class AppMetricBar extends StatelessWidget {
  const AppMetricBar({
    required this.totalTracked,
    required this.expiringSoon,
    required this.expired,
    super.key,
    this.onTapTracked,
    this.onTapExpiring,
    this.onTapExpired,
  });

  final int totalTracked;
  final int expiringSoon;
  final int expired;
  final VoidCallback? onTapTracked;
  final VoidCallback? onTapExpiring;
  final VoidCallback? onTapExpired;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _MetricColumn(
                label: 'TRACKED',
                value: totalTracked.toString(),
                valueColor: colorScheme.onSurface,
                onTap: onTapTracked,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: colors.cardBorder,
              indent: 12,
              endIndent: 12,
            ),
            Expanded(
              child: _MetricColumn(
                label: 'EXPIRING',
                value: expiringSoon.toString(),
                valueColor: colors.warningAmber,
                onTap: onTapExpiring,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: colors.cardBorder,
              indent: 12,
              endIndent: 12,
            ),
            Expanded(
              child: _MetricColumn(
                label: 'EXPIRED',
                value: expired.toString(),
                valueColor: colors.dangerRed,
                onTap: onTapExpired,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    required this.valueColor,
    this.onTap,
  });

  final String label;
  final String value;
  final Color valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: valueColor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
