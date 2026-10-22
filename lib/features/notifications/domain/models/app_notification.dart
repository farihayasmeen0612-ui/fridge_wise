import 'package:flutter/foundation.dart';

enum NotificationType {
  expiredAlert,
  expiringSoonAlert,
  hardwareEvent,
  system,
}

/// Domain model for in-app shelf-life notifications and hardware event alerts.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.relatedFoodItemId,
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? relatedFoodItemId;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? relatedFoodItemId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedFoodItemId: relatedFoodItemId ?? this.relatedFoodItemId,
    );
  }
}
