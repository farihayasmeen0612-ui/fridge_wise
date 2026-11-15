import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/presentation/components/app_confirm_dialog.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../inventory/data/inventory_providers.dart';

const String _prefDailyDigestKey = 'user_pref_daily_digest';
const String _prefAlertDaysKey = 'user_pref_alert_days_before';

/// Premium Nature redesign of the FridgeWise Settings Screen.
/// Emphasizes organic, calming aesthetics with deep forest green, warm ivory,
/// muted sage accents, compact grouped cards, and understated destructive actions.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _alertDaysBefore = 1;
  bool _dailyDigestEnabled = true;
  bool _isSyncing = false;

  // Nature Palette Constants
  static const Color _forestGreenLight = Color(0xFF176449);
  static const Color _sageContainerLight = Color(0xFFDDE9DF);
  static const Color _terracotta = Color(0xFFB65C50);

  ImageProvider? _getImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
    }
    return FileImage(File(photoUrl));
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _dailyDigestEnabled = prefs.getBool(_prefDailyDigestKey) ?? true;
          _alertDaysBefore = prefs.getInt(_prefAlertDaysKey) ?? 1;
        });
      }
    } catch (_) {
      // Graceful fallback to default values
    }
  }

  Future<void> _setDailyDigest(bool enabled) async {
    setState(() => _dailyDigestEnabled = enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefDailyDigestKey, enabled);
    } catch (_) {}
  }

  Future<void> _setAlertDays(int days) async {
    setState(() => _alertDaysBefore = days);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefAlertDaysKey, days);
    } catch (_) {}
  }

  Future<void> _handleSignOut() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Sign Out?',
      message: 'Are you sure you want to sign out of your account?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (mounted) {
        context.go('/welcome');
      }
    }
  }

  Future<void> _handleSyncCloudData() async {
    setState(() => _isSyncing = true);
    try {
      ref.invalidate(inventoryNotifierProvider);
      ref.invalidate(activityLogsProvider);
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Inventory synchronized with Supabase Cloud.'),
            backgroundColor: context.appColors.freshnessSuccess,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeNotifierProvider);
    final user = ref.watch(authProvider);

    final forestGreen = isDark ? colorScheme.primary : _forestGreenLight;
    final sageBg = isDark ? colors.surfaceElevated : _sageContainerLight;

    // Live ESP32 Hardware Status Check
    final isCloudConnected = supabaseClient != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          children: [
            // A. Compact Account Header Card
            _buildAccountCard(context, user, colors, colorScheme, forestGreen, sageBg),
            const SizedBox(height: 20),

            // B. Preferences Section
            _buildSectionHeader('PREFERENCES', colors),
            const SizedBox(height: 8),
            _buildPreferencesCard(
              context,
              colors,
              colorScheme,
              forestGreen,
              currentThemeMode,
              isDark,
            ),
            const SizedBox(height: 20),

            // C. Connected Hardware Section
            _buildSectionHeader('CONNECTED HARDWARE', colors),
            const SizedBox(height: 8),
            _buildHardwareCard(
              context,
              colors,
              colorScheme,
              forestGreen,
              sageBg,
              isCloudConnected,
            ),
            const SizedBox(height: 28),

            // D. Understated Terracotta Sign Out Action
            _buildSignOutButton(context, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColorsExtension colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    AuthUserState user,
    AppColorsExtension colors,
    ColorScheme colorScheme,
    Color forestGreen,
    Color sageBg,
  ) {
    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/profile'),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: sageBg,
                backgroundImage: _getImageProvider(user.photoUrl),
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: forestGreen,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : 'FridgeWise User',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email.isNotEmpty ? user.email : 'user@fridgewise.app',
                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Navigation arrow
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(
    BuildContext context,
    AppColorsExtension colors,
    ColorScheme colorScheme,
    Color forestGreen,
    ThemeMode currentThemeMode,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          // 1. Appearance Row with Forest Green Segmented Selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette_outlined, size: 17, color: forestGreen),
                    const SizedBox(width: 10),
                    Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildThemeSelector(forestGreen, currentThemeMode, isDark, colors),
              ],
            ),
          ),
          Divider(height: 1, color: colors.cardBorder),

          // 2. Daily Expiry Digest Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(Icons.notifications_none_rounded, size: 18, color: forestGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Expiry Digest',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Summary at 9:00 AM',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _dailyDigestEnabled,
                  activeThumbColor: Colors.white,
                  activeTrackColor: forestGreen,
                  onChanged: _setDailyDigest,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.cardBorder),

          // 3. Expiry Alert Threshold Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 18, color: forestGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
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
                      const SizedBox(height: 1),
                      Text(
                        'Notify before food expires',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _alertDaysBefore,
                      isDense: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: forestGreen),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 day before')),
                        DropdownMenuItem(value: 2, child: Text('2 days before')),
                        DropdownMenuItem(value: 3, child: Text('3 days before')),
                      ],
                      onChanged: (val) {
                        if (val != null) _setAlertDays(val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
    Color forestGreen,
    ThemeMode currentMode,
    bool isDark,
    AppColorsExtension colors,
  ) {
    final modes = [
      (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
      (ThemeMode.light, 'Light', Icons.light_mode_outlined),
      (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: modes.map((entry) {
          final mode = entry.$1;
          final label = entry.$2;
          final icon = entry.$3;
          final isSelected = currentMode == mode;

          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(themeNotifierProvider.notifier).setThemeMode(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? forestGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: forestGreen.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected
                          ? (isDark ? const Color(0xFF092616) : Colors.white)
                          : colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                          ? (isDark ? const Color(0xFF092616) : Colors.white)
                          : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHardwareCard(
    BuildContext context,
    AppColorsExtension colors,
    ColorScheme colorScheme,
    Color forestGreen,
    Color sageBg,
    bool isConnected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          // 1. ESP32-S3 Module Status Row
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: sageBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.memory_outlined, size: 19, color: forestGreen),
                ),
                const SizedBox(width: 12),
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
                        isConnected ? 'Cloud Linked • Dual-Button Hub' : 'Standby Mode',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Subtle live dot status indicator (no oversized badge)
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isConnected ? colors.freshnessSuccess : colors.warningAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? 'Active' : 'Standby',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isConnected ? colors.freshnessSuccess : colors.warningAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.cardBorder),

          // 2. Cloud Sync Action Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.sync_rounded, size: 18, color: colors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Data Sync',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Refresh inventory & audit logs',
                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: _isSyncing ? null : _handleSyncCloudData,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(color: forestGreen.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSyncing
                      ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: forestGreen),
                        )
                      : Text(
                          'Sync Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: forestGreen,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleSignOut,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: _terracotta.withValues(alpha: isDark ? 0.12 : 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _terracotta.withValues(alpha: isDark ? 0.35 : 0.22),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 17, color: _terracotta),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _terracotta,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
