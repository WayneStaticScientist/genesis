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
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

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
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedIds.clear();
                  });
                },
              )
            : (widget.triggerKey != null
                ? DrawerButton(
                    onPressed: () =>
                        widget.triggerKey?.currentState?.openDrawer(),
                  )
                : null),
        systemOverlayStyle: GTheme.copyOverlay(context),
        title: Text(
          _isSelectionMode ? '${_selectedIds.length} Selected' : 'Notifications',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedIds.length ==
                          _controller.notifications.length) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds.addAll(
                          _controller.notifications.map((n) => n.id),
                        );
                      }
                    });
                  },
                  icon: Icon(
                    _selectedIds.length == _controller.notifications.length
                        ? Icons.deselect_rounded
                        : Icons.select_all_rounded,
                    color: Colors.blueAccent,
                  ),
                  tooltip: 'Select all',
                ),
                IconButton(
                  onPressed: () {
                    if (_selectedIds.isEmpty) return;
                    Get.defaultDialog(
                      title: "Delete Selected",
                      content: Text(
                        "Are you sure you want to delete ${_selectedIds.length} selected notifications?",
                      ),
                      textCancel: "Cancel",
                      textConfirm: "Delete",
                      onConfirm: () {
                        _controller.deleteMultipleNotifications(
                          _selectedIds.toList(),
                        );
                        setState(() {
                          _selectedIds.clear();
                          _isSelectionMode = false;
                        });
                        Get.back();
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                  tooltip: 'Delete selected',
                ),
                const SizedBox(width: 8),
              ]
            : [
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
                  final notification = _controller.notifications[index];
                  final isSelected = _selectedIds.contains(notification.id);

                  return NotificationCard(
                    notification: notification,
                    isSelected: isSelected,
                    isSelectionMode: _isSelectionMode,
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        setState(() {
                          _isSelectionMode = true;
                          _selectedIds.add(notification.id);
                        });
                      }
                    },
                  ).onTap(() {
                    if (_isSelectionMode) {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(notification.id);
                          if (_selectedIds.isEmpty) {
                            _isSelectionMode = false;
                          }
                        } else {
                          _selectedIds.add(notification.id);
                        }
                      });
                    } else {
                      _controller.routeNotification(notification);
                    }
                  });
                },
              ),
      ),
    );
  }
}
