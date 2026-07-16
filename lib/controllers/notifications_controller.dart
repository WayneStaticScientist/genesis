import 'package:genesis/utils/toast.dart';
import 'package:get/get.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:genesis/utils/database_carrier.dart';
import 'package:genesis/models/notification_model.dart';
import 'package:genesis/screens/trips/trips_details_screen.dart';
import 'package:genesis/screens/maintainance/maintainance_view.dart';
import 'package:genesis/screens/notifications/service_reminders_notifications.dart';
import 'package:genesis/screens/notifications/notification_details_screen.dart';
import 'package:genesis/services/network_adapter.dart';

class NotificationsController extends GetxController {
  RxInt notificationSize = 0.obs;
  @override
  void onInit() {
    super.onInit();
    initNotifications();
  }

  Future<void> initNotifications() async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    notificationSize.value = isar.notificationModels
        .where()
        .isReadEqualTo(false)
        .count();
  }

  RxList<NotificationModel> notifications = RxList<NotificationModel>();
  Future<void> getNotifications({String search = ''}) async {
    // 1. Fetch from server first to ensure Isar has the latest notifications
    try {
      final res = await Net.get('/notifications');
      if (!res.hasError && res.body['data'] != null) {
        final serverNotes = List<Map<String, dynamic>>.from(res.body['data']);
        final isar = IsarStatic.isar;
        if (isar != null) {
          // Bulk insert/update
          await isar.write((isar) async {
            for (var data in serverNotes) {
              // Create local representation
              // The backend object has slightly different field names compared to FCM data payload
              // Make sure to map correctly for fromJSON
              final localPayload = {
                'type': data['type'],
                'channenId': data['channenId'],
                'referedId': data['referedId'],
                'title': data['title'],
                'content': data['content'],
                'date': data['date'] ?? data['createdAt'],
              };
              
              // We need to avoid duplicates. Check if a notification with this date and channelId already exists
              final exists = await isar.notificationModels
                .where()
                .channenIdEqualTo(data['channenId'])
                .and()
                .titleEqualTo(data['title'])
                .count();
                
              if (exists == 0) {
                 final n = NotificationModel.fromJSON(isar.notificationModels.autoIncrement(), localPayload);
                 n.isRead = data['isRead'] ?? false;
                 isar.notificationModels.put(n);
              }
            }
          });
        }
      }
    } catch (e) {
      print("Failed to sync notifications from backend: $e");
    }

    // 2. Load from Isar
    final isar = IsarStatic.isar;
    if (isar == null) return;
    notifications.value = await isar.notificationModels
        .where()
        .titleContains(search, caseSensitive: false)
        .or()
        .contentContains(search, caseSensitive: false)
        .sortByDateDesc()
        .findAll();
  }

  void addNotification(data) async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    final notification = NotificationModel.fromJSON(
      isar.notificationModels.autoIncrement(),
      data,
    );

    await isar.write((isar) async {
      isar.notificationModels.put(notification);
    });
    initNotifications();
    getNotifications();
  }

  void routeNotification(NotificationModel notification) async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    notification.isRead = true;
    await isar.write((isar) async {
      isar.notificationModels.put(notification);
    });
    initNotifications();
    if (notification.type == "maintainance") {
      await Get.to(
        () => MaintenanceDetailScreen(maintainance_id: notification.channenId),
      );
    } else if (notification.type == "trip") {
      await Get.to(() => TripDetailsScreen(tripId: notification.channenId));
    } else if (notification.type == "service_reminders") {
      await Get.to(() => const ServiceRemindersNotificationsScreen());
    } else {
      await Get.to(() => NotificationDetailsScreen(notification: notification));
    }
    getNotifications();
  }

  void markAllAsRead() async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    await isar.write((isar) async {
      await isar.notificationModels
          .where()
          .isReadEqualTo(false)
          .updateAll(isRead: true);
    });
    await initNotifications();
    await getNotifications();
    Toaster.showSuccess("success set on read");
  }

  void deleteNotification(NotificationModel notification) async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    await isar.write((isar) async {
      isar.notificationModels.delete(notification.id);
    });
    await initNotifications();
    await getNotifications();
    Toaster.showSuccess("success delete");
  }

  void deleteMultipleNotifications(List<int> ids) async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    await isar.write((isar) async {
      for (var id in ids) {
        isar.notificationModels.delete(id);
      }
    });
    await initNotifications();
    await getNotifications();
    Toaster.showSuccess("success delete");
  }
}
