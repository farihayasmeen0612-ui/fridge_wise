import 'package:flutter/material.dart';
import '../../theme/app_colors_extension.dart';
import 'app_button.dart';

/// Standard confirmation dialog before destructive or significant actions.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    super.key,
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.cardBorder),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: colors.textSecondary,
          height: 1.4,
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: cancelLabel,
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                label: confirmLabel,
                variant: isDestructive
                    ? AppButtonVariant.destructive
                    : AppButtonVariant.primary,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
