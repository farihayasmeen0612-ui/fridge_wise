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

/// Screen displaying all pending Food IN camera captures awaiting user verification.
/// Users can inspect thumbnails, capture times, AI recognition status, and select any
/// capture to open the intake review form.
class PendingIntakeListScreen extends ConsumerWidget {
  const PendingIntakeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final pendingIntakes = ref.watch(pendingIntakeRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pending Food Intake',
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
          child: pendingIntakes.isEmpty
              ? _buildEmptyState(context, colors, colorScheme)
              : _buildListContent(context, colors, colorScheme, pendingIntakes),
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
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.input_rounded, size: 20, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${requests.length} ${requests.length == 1 ? "Capture" : "Captures"} Awaiting Review',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap any capture to confirm food details, storage zone, and expiry date.',
                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List of Pending Intakes
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final req = requests[index];
            return _PendingIntakeCard(
              request: req,
              onTap: () => context.push('/fridge-camera?requestId=${req.id}'),
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
                  'All Intakes Reviewed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'There are no pending food captures waiting for confirmation. Press the physical IN button on the ESP32 camera to capture new items.',
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

class _PendingIntakeCard extends StatelessWidget {
  const _PendingIntakeCard({
    required this.request,
    required this.onTap,
  });

  final PendingFoodRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final bool isFoodDetected =
        request.hasFood && (request.aiDetectedName != null && request.aiDetectedName!.trim().isNotEmpty);

    final timeLabel = DateFormat('MMM d, h:mm a').format(request.timestamp.toLocal());

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isFoodDetected ? colors.cardBorder : colors.warningAmber.withValues(alpha: 0.4),
          width: 1.0,
        ),
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
                          title: isFoodDetected ? request.aiDetectedName! : 'ESP32 IN Capture',
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
                            color: isFoodDetected ? colors.freshnessContainer : colors.warningContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isFoodDetected ? 'ESP32 INTAKE' : 'ALERT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isFoodDetected ? colors.freshnessSuccess : colors.warningAmber,
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

                    // Food Title
                    Text(
                      isFoodDetected ? request.aiDetectedName! : 'No Food Detected',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // AI Status Indicator
                    Row(
                      children: [
                        Icon(
                          isFoodDetected ? Icons.auto_awesome_rounded : Icons.warning_amber_rounded,
                          size: 13,
                          color: isFoodDetected ? colorScheme.primary : colors.warningAmber,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isFoodDetected
                                ? (request.aiCategory != null && request.aiCategory!.isNotEmpty
                                    ? 'Identified as ${request.aiCategory}'
                                    : 'Recognized by Gemini AI')
                                : 'Non-food / Unrecognized item',
                            style: TextStyle(
                              fontSize: 11,
                              color: isFoodDetected ? colors.textSecondary : colors.warningAmber,
                              fontWeight: isFoodDetected ? FontWeight.w500 : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

