import 'package:flutter/material.dart';
import '../../../features/inventory/domain/models/food_item.dart';
import '../../theme/app_colors_extension.dart';
import 'app_status_pill.dart';

/// High-density food item row designed for rapid visual scanning and kitchen-first ergonomics.
class AppFoodRow extends StatelessWidget {
  const AppFoodRow({
    required this.item,
    required this.onTap,
    super.key,
    this.onTrailingAction,
  });

  final FoodItem item;
  final VoidCallback onTap;
  final VoidCallback? onTrailingAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Category icon / Thumbnail container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Center(
                  child: Icon(
                    item.category.icon,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          item.category.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.cardBorder,
                          ),
                        ),
                        Text(
                          item.storageLocation.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Quantity and status badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppStatusPill(
                    status: item.expiryStatus,
                    label: item.countdownLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
