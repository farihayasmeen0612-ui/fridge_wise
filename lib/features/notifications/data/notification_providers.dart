import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/app_notification.dart';

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    final now = DateTime.now();

    return [
      AppNotification(
        id: 'notif-1',
        title: 'Item Expired',
        message: 'Orange Juice expired 2 days ago in Fridge. Discard to maintain hygiene.',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: NotificationType.expiredAlert,
        isRead: false,
        relatedFoodItemId: 'seed-item-1',
      ),
      AppNotification(
        id: 'notif-2',
        title: 'Expires Today',
        message: 'Fresh Salmon Fillet should be cooked or frozen today.',
        timestamp: now.subtract(const Duration(hours: 5)),
        type: NotificationType.expiringSoonAlert,
        isRead: false,
        relatedFoodItemId: 'seed-item-2',
      ),
      AppNotification(
        id: 'notif-3',
        title: 'Simulated Hardware Trigger',
        message: 'ESP32 CAM captured an intake scan. Ready for review.',
        timestamp: now.subtract(const Duration(hours: 8)),
        type: NotificationType.hardwareEvent,
        isRead: true,
      ),
    ];
  }

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void clearAll() {
    state = [];
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
