import 'package:flutter/foundation.dart';
import '../../../inventory/domain/models/expiry_status.dart';
import '../../../inventory/domain/models/food_item.dart';

/// Aggregated metrics for the dashboard KPI cards and urgency alerts.
@immutable
class InventorySummary {
  const InventorySummary({
    required this.totalActive,
    required this.freshCount,
    required this.expiringSoonCount,
    required this.expiredCount,
  });

  final int totalActive;
  final int freshCount;
  final int expiringSoonCount;
  final int expiredCount;

  bool get hasExpiredItems => expiredCount > 0;
  bool get hasUrgentItems => expiredCount > 0 || expiringSoonCount > 0;

  factory InventorySummary.empty() {
    return const InventorySummary(
      totalActive: 0,
      freshCount: 0,
      expiringSoonCount: 0,
      expiredCount: 0,
    );
  }

  factory InventorySummary.fromItems(List<FoodItem> items) {
    int total = 0;
    int fresh = 0;
    int expiringSoon = 0;
    int expired = 0;

    for (final item in items) {
      if (item.status != ItemStatus.active) continue;
      total++;
      switch (item.expiryStatus) {
        case ExpiryStatus.fresh:
          fresh++;
          break;
        case ExpiryStatus.expiringSoon:
          expiringSoon++;
          break;
        case ExpiryStatus.expired:
          expired++;
          break;
      }
    }

    return InventorySummary(
      totalActive: total,
      freshCount: fresh,
      expiringSoonCount: expiringSoon,
      expiredCount: expired,
    );
  }
}
