import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extension.dart';

/// Phase 1 Placeholder for the Expiry Calendar & Agenda screen.
class ExpiryCalendarScreen extends StatelessWidget {
  const ExpiryCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expiry Calendar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 48,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Shelf-Life Calendar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calendar view and daily agenda will be integrated in upcoming phases.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
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
