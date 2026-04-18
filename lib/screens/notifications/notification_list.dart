import 'package:genesis/models/notification_model.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/layouts/notifications_card.dart';
import 'package:genesis/controllers/notifications_controller.dart';

// Assuming your NotificationModel is available in your project.
// This UI implementation uses a simulated list of that model.

class NotificationListScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const NotificationListScreen({super.key, this.triggerKey});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final _controller = Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    _controller.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: widget.triggerKey != null
            ? DrawerButton(
                onPressed: () => widget.triggerKey?.currentState?.openDrawer(),
              )
            : null,
        systemOverlayStyle: GTheme.copyOverlay(context),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _controller.markAllAsRead();
            },
            icon: const Icon(Icons.done_all, color: Colors.blueAccent),
            tooltip: 'Mark all as read',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(
        () => _controller.notifications.isEmpty
            ? const Center(child: Text('No notifications yet'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _controller.notifications.length,
                itemBuilder: (context, index) {
                  return NotificationCard(
                    notification: _controller.notifications[index],
                    onLongPress: () =>
                        _openDialog(context, _controller.notifications[index]),
                  ).onTap(() {
                    _controller.routeNotification(
                      _controller.notifications[index],
                    );
                  });
                },
              ),
      ),
    );
  }

  _openDialog(BuildContext context, NotificationModel notification) {
    Get.defaultDialog(
      title: "Delete Notification",
      content: Text(
        "Are you sure you want to delete this notification? ${notification.title}",
      ),
      textCancel: "close",
      textConfirm: "Delete",
      onConfirm: () {
        _controller.deleteNotification(notification);
        Get.back();
      },
    );
  }
}
