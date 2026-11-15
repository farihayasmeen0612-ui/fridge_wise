import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/app_confirm_dialog.dart';
import '../../../../core/presentation/components/app_food_row.dart';
import '../../../../core/presentation/components/app_metric_bar.dart';
import '../../../../core/presentation/components/theme_toggle_button.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../inventory/data/inventory_providers.dart';
import '../../../notifications/data/notification_providers.dart';
import '../../../recipes/data/mock_recipe_repository.dart';
import '../../../scan/data/pending_requests_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getGreeting(AuthUserState user) {
    final timeGreeting = _getTimeGreeting();
    final rawName = user.name.trim();

    // Sensible fallback if name is empty, an email address, or matches the email prefix/username
    if (rawName.isEmpty || rawName.contains('@')) {
      return '$timeGreeting!';
    }

    if (user.email.isNotEmpty) {
      final emailPrefix = user.email.split('@').first.toLowerCase();
      if (rawName.toLowerCase() == emailPrefix) {
        return '$timeGreeting!';
      }
    }

    // If the name is formatted as a username with digits and no space, fallback
    if (RegExp(r'\d').hasMatch(rawName) && !rawName.contains(' ')) {
      return '$timeGreeting!';
    }

    // Extract first token from full name
    final parts = rawName.split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '$timeGreeting!';
    }

    final firstName = parts.first;
    final formattedName = firstName[0].toUpperCase() + firstName.substring(1);
    return '$timeGreeting, $formattedName!';
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Sign Out?',
      message: 'Are you sure you want to sign out of your account?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) {
        context.go('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider);
    final summary = ref.watch(inventorySummaryProvider);
    final urgentItems = ref.watch(urgentItemsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final recipes = ref.watch(recipesListProvider);
    final topRecipe = recipes.isNotEmpty ? recipes.first : null;
    final pendingIntakes = ref.watch(pendingIntakeRequestsProvider);
    final pendingTakeouts = ref.watch(pendingTakeOutRequestsProvider);
    final pendingTotal = pendingIntakes.length + pendingTakeouts.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getGreeting(user),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              backgroundColor: colors.dangerRed,
              child: Icon(Icons.notifications_outlined, size: 24, color: colorScheme.onSurface),
            ),
            onPressed: () => context.push('/notifications'),
            tooltip: 'Notification Center',
          ),
          const SizedBox(width: 4),
          const Center(
            child: ThemeToggleButton(),
          ),
          const SizedBox(width: 8),
          Center(
            child: Tooltip(
              message: 'Sign Out',
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? colors.dangerRed.withValues(alpha: 0.16)
                      : colors.dangerRed.withValues(alpha: 0.08),
                  border: Border.all(
                    color: isDark
                        ? colors.dangerRed.withValues(alpha: 0.5)
                        : colors.dangerRed.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : colors.dangerRed).withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _handleSignOut(context, ref),
                    child: Center(
                      child: Image.asset(
                        'assets/images/sign_out.png',
                        width: 20,
                        height: 20,
                        color: isDark ? Colors.white : Colors.black,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Urgency Alert Banner (Conditional)
                if (summary.hasExpiredItems) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.dangerContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.dangerBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 20, color: colors.dangerRed),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${summary.expiredCount} item has expired. Review and discard to keep fridge fresh.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.dangerRed,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/inventory'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'View',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.dangerRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 2. Metric KPI Bar
                AppMetricBar(
                  totalTracked: summary.totalActive,
                  expiringSoon: summary.expiringSoonCount,
                  expired: summary.expiredCount,
                  onTapTracked: () => context.go('/inventory'),
                  onTapExpiring: () => context.go('/expiry'),
                  onTapExpired: () => context.go('/expiry'),
                ),
                const SizedBox(height: 16),

                // 2b. Pending Requests Awaiting Confirmation Banner
                if (pendingTotal > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.notifications_active_rounded, size: 16, color: colorScheme.primary),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'REQUESTS AWAITING CONFIRMATION ($pendingTotal)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Camera captured new food activity. Confirm or edit details whenever convenient.',
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (pendingIntakes.isNotEmpty)
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    side: BorderSide(color: colorScheme.primary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.input_rounded, size: 16),
                                  label: Text(
                                    'Review Intake (${pendingIntakes.length})',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () => context.push('/pending-intakes'),
                                ),
                              ),
                            if (pendingIntakes.isNotEmpty && pendingTakeouts.isNotEmpty)
                              const SizedBox(width: 10),
                            if (pendingTakeouts.isNotEmpty)
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    side: BorderSide(color: colors.warningAmber),
                                    foregroundColor: colors.warningAmber,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.output_rounded, size: 16),
                                  label: Text(
                                    'Review Removal (${pendingTakeouts.length})',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () => context.push('/pending-removals'),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Food Approaching Expiry Section (Needs attention)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Needs Attention Soon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (urgentItems.isNotEmpty)
                      GestureDetector(
                        onTap: () => context.go('/expiry'),
                        child: Text(
                          'See Calendar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (urgentItems.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Center(
                      child: Text(
                        'All tracked food items are currently fresh.',
                        style: TextStyle(color: colors.textSecondary, fontSize: 14),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: urgentItems.take(4).length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = urgentItems[index];
                      return AppFoodRow(
                        item: item,
                        onTap: () => context.push('/food-details/${item.id}'),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                // 6. Zero-Waste Recipe Recommendation Section
                if (topRecipe != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Zero-Waste Recipe Idea',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/recipes'),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colors.cardBorder),
                    ),
                    child: InkWell(
                      onTap: () => context.push('/recipe-details/${topRecipe.id}'),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colors.freshnessContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'USES EXPIRING ITEMS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: colors.freshnessSuccess,
                                        letterSpacing: 0.4,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${topRecipe.prepTimeMinutes} min • ${topRecipe.difficulty}',
                                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              topRecipe.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topRecipe.description,
                              style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
