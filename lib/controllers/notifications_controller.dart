import 'package:genesis/utils/toast.dart';
import 'package:get/get.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:genesis/utils/database_carrier.dart';
import 'package:genesis/models/notification_model.dart';
import 'package:genesis/screens/trips/trips_details_screen.dart';
import 'package:genesis/screens/maintainance/maintainance_view.dart';

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
    final isar = IsarStatic.isar;
    if (isar == null) return;
    notifications.value = await isar.notificationModels
        .where()
        .titleContains(search, caseSensitive: false)
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
    }
    if (notification.type == "trip") {
      await Get.to(() => TripDetailsScreen(tripId: notification.channenId));
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
}
