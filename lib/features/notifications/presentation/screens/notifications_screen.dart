import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/components/app_empty_state.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../data/notification_providers.dart';
import '../../domain/models/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark all read'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No Notifications',
                description: 'You are all caught up! New expiry and camera alerts will appear here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _NotificationTile(notification: notif);
                },
              ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.expiredAlert:
        icon = Icons.error_outline_rounded;
        iconColor = colors.dangerRed;
        break;
      case NotificationType.expiringSoonAlert:
        icon = Icons.schedule_rounded;
        iconColor = colors.warningAmber;
        break;
      case NotificationType.hardwareEvent:
        icon = Icons.videocam_outlined;
        iconColor = colors.secondaryAction;
        break;
      case NotificationType.system:
        icon = Icons.info_outline_rounded;
        iconColor = colorScheme.primary;
        break;
    }

    final timeStr = DateFormat('h:mm a').format(notification.timestamp);

    return Material(
      color: notification.isRead ? colorScheme.surface : colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? colors.cardBorder : colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(notificationsProvider.notifier).markAsRead(notification.id);
          if (notification.relatedFoodItemId != null) {
            context.push('/food-details/${notification.relatedFoodItemId}');
          } else if (notification.type == NotificationType.hardwareEvent) {
            context.push('/scan-workflow?mode=in');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(fontSize: 11, color: colors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
