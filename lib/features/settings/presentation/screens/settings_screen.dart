import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_confirm_dialog.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../inventory/data/inventory_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _alertDaysBefore = 1;
  bool _dailyDigestEnabled = true;

  Future<void> _handleSignOut() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Sign Out?',
      message: 'Are you sure you want to sign out of your smart fridge profile?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (mounted) {
        context.go('/auth/login');
      }
    }
  }

  Future<void> _handleResetData() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Reset Demo Inventory?',
      message: 'This will reset your local fridge inventory back to the 10 initial sample items.',
      confirmLabel: 'Reset Data',
      isDestructive: false,
    );

    if (confirmed == true && mounted) {
      ref.invalidate(inventoryNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Inventory reset to default seed items.'),
          backgroundColor: context.appColors.freshnessSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final currentThemeMode = ref.watch(themeNotifierProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.freshnessContainer,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.freshnessSuccess,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: TextStyle(fontSize: 13, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Appearance
            _SectionHeader(title: 'APPEARANCE'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Preference',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose how the application appears across light and dark environments.',
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.brightness_auto_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_rounded),
                        ),
                      ],
                      selected: {currentThemeMode},
                      onSelectionChanged: (newSelection) {
                        ref
                            .read(themeNotifierProvider.notifier)
                            .setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Expiry Notifications
            _SectionHeader(title: 'EXPIRY NOTIFICATIONS'),
            const SizedBox(height: 8),
            Material(
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: colors.cardBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Daily Expiry Digest'),
                    subtitle: const Text('Receive a daily 9:00 AM summary of items nearing expiry'),
                    value: _dailyDigestEnabled,
                    onChanged: (val) => setState(() => _dailyDigestEnabled = val),
                  ),
                  Divider(height: 1, color: colors.cardBorder),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alert Threshold',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Notify when item reaches',
                              style: TextStyle(fontSize: 12, color: colors.textSecondary),
                            ),
                          ],
                        ),
                        DropdownButton<int>(
                          value: _alertDaysBefore,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1 day before')),
                            DropdownMenuItem(value: 2, child: Text('2 days before')),
                            DropdownMenuItem(value: 3, child: Text('3 days before')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _alertDaysBefore = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Hardware Connection
            _SectionHeader(title: 'CONNECTED HARDWARE'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Icon(Icons.memory_rounded, size: 22, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ESP32-S3 CAM Module',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bench Mock Mode (Ready for Phase 7 WiFi pairing)',
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.freshnessContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'READY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colors.freshnessSuccess,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 4: Data Management & Reset
            _SectionHeader(title: 'DATA MANAGEMENT'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Mock Inventory',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Restore the sample inventory with 10 seed items across all categories and status tiers.',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Reset to Sample Data',
                    variant: AppButtonVariant.secondary,
                    onPressed: _handleResetData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sign Out Button
            AppButton(
              label: 'Sign Out',
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.destructive,
              isFullWidth: true,
              onPressed: _handleSignOut,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: context.appColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
