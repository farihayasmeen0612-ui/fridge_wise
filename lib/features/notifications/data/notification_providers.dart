import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scan/data/pending_requests_provider.dart';
import '../domain/models/app_notification.dart';

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  final Set<String> _readIds = {};
  final List<AppNotification> _manualNotifications = [];

  @override
  List<AppNotification> build() {
    final pendingRequests = ref.watch(pendingRequestsProvider);

    final pendingNotifications = pendingRequests.map((req) {
      final notifId = 'notif_pending_${req.id}';
      final isRead = _readIds.contains(notifId);

      if (req.isIntake) {
        final bool isFoodDetected =
            req.hasFood && (req.aiDetectedName != null && req.aiDetectedName!.trim().isNotEmpty);
        return AppNotification(
          id: notifId,
          title: isFoodDetected
              ? 'Food Intake Waiting for Review'
              : 'New Capture Waiting for Review',
          message: isFoodDetected
              ? 'ESP32 camera identified "${req.aiDetectedName}". Tap to verify and confirm.'
              : 'Camera captured an image with no food detected. Tap to review or delete.',
          timestamp: req.timestamp,
          type: NotificationType.hardwareEvent,
          isRead: isRead,
          relatedRequestId: req.id,
          requestType: 'in',
        );
      } else {
        return AppNotification(
          id: notifId,
          title: 'Food Removal Waiting for Review',
          message:
              'Physical OUT button pressed. Tap to inspect captured photo and select removed items.',
          timestamp: req.timestamp,
          type: NotificationType.hardwareEvent,
          isRead: isRead,
          relatedRequestId: req.id,
          requestType: 'out',
        );
      }
    }).toList();

    return [
      ...pendingNotifications,
      ..._manualNotifications.map((n) => n.copyWith(isRead: _readIds.contains(n.id))),
    ];
  }

  void markAsRead(String id) {
    _readIds.add(id);
    ref.invalidateSelf();
  }

  void markAllAsRead() {
    for (final notif in state) {
      _readIds.add(notif.id);
    }
    ref.invalidateSelf();
  }

  void clearAll() {
    for (final notif in state) {
      _readIds.add(notif.id);
    }
    _manualNotifications.clear();
    ref.invalidateSelf();
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.where((n) => !n.isRead).length;
});
