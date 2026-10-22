import 'package:flutter/foundation.dart';
import 'food_category.dart';

/// Type of inventory action tracked in the audit log.
enum LogActionType {
  added(label: 'Added to Fridge'),
  consumed(label: 'Consumed'),
  discarded(label: 'Discarded'),
  updated(label: 'Updated Details');

  const LogActionType({required this.label});
  final String label;
}

/// Audit record of an inventory modification, intake, consumption, or waste event.
@immutable
class ActivityLogItem {
  const ActivityLogItem({
    required this.id,
    required this.actionType,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.timestamp,
    this.notes,
  });

  final String id;
  final LogActionType actionType;
  final String itemName;
  final FoodCategory category;
  final double quantity;
  final String unit;
  final DateTime timestamp;
  final String? notes;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionType': actionType.name,
      'itemName': itemName,
      'category': category.name,
      'quantity': quantity,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory ActivityLogItem.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return ActivityLogItem(
      id: documentId ?? map['id'] as String? ?? '',
      actionType: LogActionType.values.firstWhere(
        (a) => a.name == map['actionType'],
        orElse: () => LogActionType.added,
      ),
      itemName: map['itemName'] as String? ?? 'Unknown Item',
      category: FoodCategory.fromString(map['category'] as String?),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] as String? ?? 'pcs',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      notes: map['notes'] as String?,
    );
  }
}
