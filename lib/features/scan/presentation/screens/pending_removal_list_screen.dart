import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_image_zoom_dialog.dart';
import '../../../../core/presentation/components/theme_toggle_button.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../data/pending_requests_provider.dart';
import '../../domain/models/pending_food_request.dart';

/// Screen displaying all pending Food OUT camera captures awaiting user verification.
/// Users can inspect thumbnails, capture times, and select any capture to open the
/// removal review form where they choose which inventory items were taken out.
class PendingRemovalListScreen extends ConsumerWidget {
  const PendingRemovalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final pendingRemovals = ref.watch(pendingTakeOutRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pending Food Removal',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: const [
          Center(child: ThemeToggleButton()),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(pendingRequestsProvider.notifier).refresh(),
          child: pendingRemovals.isEmpty
              ? _buildEmptyState(context, colors, colorScheme)
              : _buildListContent(context, colors, colorScheme, pendingRemovals),
        ),
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context,
    AppColorsExtension colors,
    ColorScheme colorScheme,
    List<PendingFoodRequest> requests,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      children: [
        // Header Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.warningAmber.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.warningContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.output_rounded, size: 20, color: colors.warningAmber),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${requests.length} ${requests.length == 1 ? "Removal" : "Removals"} Awaiting Review',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap any capture to inspect the photo and select removed food items.',
                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List of Pending Removals
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final req = requests[index];
            return _PendingRemovalCard(
              request: req,
              onTap: () => context.push('/take-out?requestId=${req.id}'),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppColorsExtension colors,
    ColorScheme colorScheme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.freshnessContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 40,
                    color: colors.freshnessSuccess,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'All Removals Reviewed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'There are no pending takeout captures waiting for confirmation. Press the physical OUT button on the ESP32 camera when removing food.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Back to Dashboard',
                  icon: Icons.dashboard_outlined,
                  variant: AppButtonVariant.primary,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingRemovalCard extends StatelessWidget {
  const _PendingRemovalCard({
    required this.request,
    required this.onTap,
  });

  final PendingFoodRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final timeLabel = DateFormat('MMM d, h:mm a').format(request.timestamp.toLocal());

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.cardBorder, width: 1.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Photo Thumbnail (tap opens full-screen image viewer)
              GestureDetector(
                onTap: request.imageUrl.isNotEmpty
                    ? () => AppImageZoomDialog.show(
                          context,
                          imageUrl: request.imageUrl,
                          title: 'ESP32 OUT Capture',
                        )
                    : null,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: colors.surfaceElevated,
                    border: Border.all(color: colors.cardBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    request.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.kitchen_rounded, color: colorScheme.primary, size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Description Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge & Timestamp Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.warningContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ESP32 OUT CAPTURE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: colors.warningAmber,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeLabel,
                          style: TextStyle(fontSize: 10, color: colors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Removal Title
                    Text(
                      'Food Removal Request',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Verification reminder
                    Text(
                      'Tap to inspect photo & select removed items',
                      style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Trailing chevron
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

