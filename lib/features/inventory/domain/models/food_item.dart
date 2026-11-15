import 'package:flutter/foundation.dart';
import '../utils/expiry_calculator.dart';
import 'expiry_status.dart';
import 'storage_location.dart';

/// Core domain model representing a tracked food item in the smart fridge system.
@immutable
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.storageLocation,
    required this.purchaseDate,
    required this.expiryDate,
    required this.quantity,
    this.unit = 'pcs',
    this.status = ItemStatus.active,
    this.notes,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? purchaseDate;

  final String id;
  final String name;
  final StorageLocation storageLocation;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double quantity;
  final String unit;
  final ItemStatus status;
  final String? notes;
  final String? imageUrl;
  final DateTime createdAt;

  // --- Dynamic Shelf-Life Helpers ---
  int get daysRemaining => ExpiryCalculator.calculateDaysRemaining(expiryDate);
  ExpiryStatus get expiryStatus => ExpiryCalculator.calculateStatus(expiryDate);
  String get countdownLabel => ExpiryCalculator.formatCountdown(expiryDate);
  bool get isExpired => expiryStatus == ExpiryStatus.expired;
  bool get isExpiringSoon => expiryStatus == ExpiryStatus.expiringSoon;
  bool get isFresh => expiryStatus == ExpiryStatus.fresh;

  FoodItem copyWith({
    String? id,
    String? name,
    StorageLocation? storageLocation,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? quantity,
    String? unit,
    ItemStatus? status,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      storageLocation: storageLocation ?? this.storageLocation,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'storageLocation': storageLocation.name,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'status': status.name,
      'notes': notes,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return FoodItem(
      id: documentId ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unnamed Item',
      storageLocation: StorageLocation.fromString(map['storageLocation'] as String?),
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.parse(map['purchaseDate'] as String).toLocal()
          : DateTime.now(),
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'] as String).toLocal()
          : DateTime.now().add(const Duration(days: 7)),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] as String? ?? 'pcs',
      status: ItemStatus.fromString(map['status'] as String?),
      notes: map['notes'] as String?,
      imageUrl: map['imageUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toLocal()
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.id == id &&
        other.name == name &&
        other.storageLocation == storageLocation &&
        other.purchaseDate == purchaseDate &&
        other.expiryDate == expiryDate &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.status == status &&
        other.notes == notes &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      storageLocation,
      purchaseDate,
      expiryDate,
      quantity,
      unit,
      status,
      notes,
      imageUrl,
    );
  }
}
