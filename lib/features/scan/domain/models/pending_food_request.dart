import 'package:flutter/foundation.dart';

enum PendingRequestType {
  intake,   // FOOD IN (ESP32 IN button capture + Gemini AI identification)
  takeout,  // FOOD OUT (ESP32 OUT button capture, visual verification only, NO AI)
}

/// Represents an unconfirmed food intake or removal request captured by the ESP32-S3 camera.
/// These requests remain pending in Supabase until the user manually confirms or dismisses them.
@immutable
class PendingFoodRequest {
  const PendingFoodRequest({
    required this.id,
    required this.filename,
    required this.type,
    required this.imageUrl,
    required this.timestamp,
    this.hasFood = true,
    this.aiDetectedName,
    this.aiCategory,
    this.notes,
    this.isConfirmed = false,
  });

  final String id;
  final String filename;
  final PendingRequestType type;
  final String imageUrl;
  final DateTime timestamp;
  final bool hasFood;
  final String? aiDetectedName;
  final String? aiCategory;
  final String? notes;
  final bool isConfirmed;

  bool get isIntake => type == PendingRequestType.intake;
  bool get isTakeout => type == PendingRequestType.takeout;

  PendingFoodRequest copyWith({
    String? id,
    String? filename,
    PendingRequestType? type,
    String? imageUrl,
    DateTime? timestamp,
    bool? hasFood,
    String? aiDetectedName,
    String? aiCategory,
    String? notes,
    bool? isConfirmed,
  }) {
    return PendingFoodRequest(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      hasFood: hasFood ?? this.hasFood,
      aiDetectedName: aiDetectedName ?? this.aiDetectedName,
      aiCategory: aiCategory ?? this.aiCategory,
      notes: notes ?? this.notes,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

/// Represents a specific food deduction chosen by the user during take-out confirmation.
@immutable
class FoodDeduction {
  const FoodDeduction({
    required this.foodItemId,
    required this.foodItemName,
    required this.quantity,
    this.unit = 'pcs',
  });

  final String foodItemId;
  final String foodItemName;
  final double quantity;
  final String unit;
}

