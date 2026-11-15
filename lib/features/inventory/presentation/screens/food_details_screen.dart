import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_confirm_dialog.dart';
import '../../../../core/presentation/components/app_image_zoom_dialog.dart';
import '../../../../core/presentation/components/app_status_pill.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../data/inventory_providers.dart';
import '../../domain/models/food_item.dart';

class FoodDetailsScreen extends ConsumerStatefulWidget {
  const FoodDetailsScreen({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends ConsumerState<FoodDetailsScreen> {
  late String _currentItemId;

  @override
  void initState() {
    super.initState();
    _currentItemId = widget.itemId;
  }

  void _openImageZoom(BuildContext context, String imageUrl, String title) {
    AppImageZoomDialog.show(context, imageUrl: imageUrl, title: title);
  }

  void _openConsumptionSheet(FoodItem item) {
    double deductQty = 1.0;
    if (item.quantity <= 1.0) {
      deductQty = item.quantity;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final remaining = item.quantity - deductQty;
            final isFull = remaining <= 0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Log Food Consumption',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deduct the amount used from your tracked fridge inventory.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity Stepper
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.appColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount to deduct:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded),
                              onPressed: deductQty > 0.5
                                  ? () => setModalState(() => deductQty -= 0.5)
                                  : null,
                            ),
                            Text(
                              '${deductQty % 1 == 0 ? deductQty.toInt() : deductQty} ${item.unit}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded),
                              onPressed: deductQty < item.quantity
                                  ? () => setModalState(() => deductQty += 0.5)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Remaining status calculation
                  Text(
                    isFull
                        ? 'Item will be marked as completely finished.'
                        : 'Remaining stock will be: ${(remaining % 1 == 0 ? remaining.toInt() : remaining.toStringAsFixed(1))} ${item.unit}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isFull
                          ? context.appColors.warningAmber
                          : context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    label: isFull ? 'Mark as Finished' : 'Confirm Deduction',
                    variant: AppButtonVariant.primary,
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      Navigator.of(ctx).pop();
                      await ref
                          .read(inventoryNotifierProvider.notifier)
                          .markConsumed(item.id, quantity: deductQty);
                      if (mounted && isFull) {
                        nav.pop();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleDiscard(FoodItem item) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Discard Spoiled Item?',
      message: 'Are you sure you want to discard "${item.name}"? This action logs the waste to help you optimize future grocery planning.',
      confirmLabel: 'Discard Item',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(inventoryNotifierProvider.notifier).markDiscarded(item.id);
      if (mounted) context.pop();
    }
  }

  Future<void> _handleDelete(FoodItem item) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete from Inventory?',
      message: 'Permanently remove "${item.name}" from your fridge inventory without logging food waste?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(inventoryNotifierProvider.notifier).deleteItem(item.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final items = ref.watch(inventoryNotifierProvider);

    final item = items.cast<FoodItem?>().firstWhere(
          (i) => i?.id == _currentItemId || i?.id == widget.itemId,
          orElse: () => items.cast<FoodItem?>().firstWhere(
            (i) =>
                i != null &&
                (widget.itemId.contains(i.name.toLowerCase().replaceAll(RegExp(r'\s+'), '_')) ||
                    (i.id.startsWith('sp_') && widget.itemId.startsWith('sp_'))),
            orElse: () => null,
          ),
        );

    if (item != null && item.id != _currentItemId) {
      _currentItemId = item.id;
    }

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Details')),
        body: const Center(child: Text('Item not found or already removed.')),
      );
    }

    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final hasPhoto = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Item',
            onPressed: () async {
              await context.push('/food-form?id=${item.id}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Item',
            onPressed: () => _handleDelete(item),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero card with category icon & primary title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: hasPhoto ? () => _openImageZoom(context, item.imageUrl!, item.name) : null,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.cardBorder),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: hasPhoto
                            ? Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Icon(
                                    item.storageLocation.icon,
                                    size: 28,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  item.storageLocation.icon,
                                  size: 28,
                                  color: colorScheme.primary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              AppStatusPill(
                                status: item.expiryStatus,
                                label: item.countdownLabel,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Shelf-Life & Storage Details Card
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
                      'Storage & Expiry Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Expiration Date',
                      value: dateFormat.format(item.expiryDate.toLocal()),
                      highlightColor: item.isExpired
                          ? colors.dangerRed
                          : item.isExpiringSoon
                              ? colors.warningAmber
                              : null,
                    ),
                    Divider(height: 20, color: colors.cardBorder),

                    _DetailRow(
                      icon: Icons.history_rounded,
                      label: 'Date Added',
                      value: dateFormat.format(item.purchaseDate.toLocal()),
                    ),
                    Divider(height: 20, color: colors.cardBorder),

                    _DetailRow(
                      icon: Icons.kitchen_rounded,
                      label: 'Storage Compartment',
                      value: item.storageLocation.label,
                    ),

                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      Divider(height: 20, color: colors.cardBorder),
                      _DetailRow(
                        icon: Icons.notes_rounded,
                        label: 'Notes & Storage Advice',
                        value: item.notes!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              AppButton(
                label: 'Log Food Consumption',
                icon: Icons.restaurant_rounded,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                onPressed: () => _openConsumptionSheet(item),
              ),
              const SizedBox(height: 12),

              AppButton(
                label: 'Discard as Food Waste',
                icon: Icons.delete_sweep_outlined,
                variant: AppButtonVariant.destructive,
                isFullWidth: true,
                onPressed: () => _handleDiscard(item),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlightColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: highlightColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
