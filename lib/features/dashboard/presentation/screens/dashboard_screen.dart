import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_food_row.dart';
import '../../../../core/presentation/components/app_metric_bar.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../inventory/data/inventory_providers.dart';
import '../../../notifications/data/notification_providers.dart';
import '../../../recipes/data/mock_recipe_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider);
    final summary = ref.watch(inventorySummaryProvider);
    final urgentItems = ref.watch(urgentItemsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final recipes = ref.watch(recipesListProvider);
    final topRecipe = recipes.isNotEmpty ? recipes.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getTimeGreeting()}, ${user.name}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              'Smart Fridge Monitor',
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
          const SizedBox(width: 8),
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

                // 3. Quick Action Buttons (IN & OUT Workflows)
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Add Food (IN)',
                        icon: Icons.add_rounded,
                        variant: AppButtonVariant.primary,
                        onPressed: () => context.push('/scan-workflow?mode=in'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Take Out (OUT)',
                        icon: Icons.remove_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => context.push('/scan-workflow?mode=out'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Pending Review Section (Simulated hardware scan queue)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.secondaryAction.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.videocam_outlined, size: 20, color: colors.secondaryAction),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fridge Camera Ready',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Press hardware button or simulate scan below.',
                              style: TextStyle(fontSize: 12, color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/scan-workflow?mode=in'),
                        child: const Text('Simulate'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Food Approaching Expiry Section (Needs attention)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Needs Attention Soon',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
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
                                Container(
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
                                  ),
                                ),
                                const Spacer(),
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
