import 'package:flutter/material.dart';
import 'package:genesis/models/notification_model.dart';
import 'package:genesis/utils/theme.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  // Helper to determine icon and color based on type
  Map<String, dynamic> _getTypeAttributes() {
    switch (notification.type.toLowerCase()) {
      case 'maintainance':
        return {'icon': Icons.car_crash, 'color': Colors.red};
      case 'trip':
        return {'icon': Icons.route, 'color': Colors.green};
      case 'alert':
        return {'icon': Icons.priority_high_rounded, 'color': Colors.redAccent};
      default:
        return {'icon': Icons.notifications_none, 'color': Colors.grey};
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final attrs = _getTypeAttributes();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: GTheme.isDark(context)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Unread indicator bar
              if (!notification.isRead)
                Container(width: 4, color: Colors.green),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leading Icon Circle
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (attrs['color'] as Color).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          attrs['icon'],
                          color: notification.isRead
                              ? attrs['color']
                              : Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notification.type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  _formatDate(notification.date),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                color: notification.isRead
                                    ? null
                                    : Colors.green,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
