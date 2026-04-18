import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/controllers/notifications_controller.dart';
import 'package:genesis/controllers/vehicle_controller.dart';
import 'package:genesis/screens/stats/vehicle_stats.dart';

class ServiceRemindersNotificationsScreen extends StatefulWidget {
  const ServiceRemindersNotificationsScreen({super.key});

  @override
  State<ServiceRemindersNotificationsScreen> createState() =>
      _ServiceRemindersNotificationsScreenState();
}

class _ServiceRemindersNotificationsScreenState
    extends State<ServiceRemindersNotificationsScreen> {
  final _controller = Get.find<NotificationsController>();
  final _vehicleController = Get.find<VehicleControler>();

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
        systemOverlayStyle: GTheme.copyOverlay(context),
        title: const Text(
          'Service Reminders Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Obx(() {
        final serviceRemindersNotifications = _controller.notifications
            .where((notification) => notification.type == 'service_reminders')
            .toList();

        if (serviceRemindersNotifications.isEmpty) {
          return const Center(child: Text('No service reminder notifications'));
        }

        return ListView.builder(
          itemCount: serviceRemindersNotifications.length,
          itemBuilder: (context, index) {
            final notification = serviceRemindersNotifications[index];
            final vehicleId = notification.channenId;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(notification.content),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${notification.date.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await _vehicleController.fetchVehicle(id: vehicleId);
                        if (_vehicleController.selectedVehicle.value != null) {
                          Get.to(
                            () => VehicleDetailStatsScreen(
                              vehicle:
                                  _vehicleController.selectedVehicle.value!,
                            ),
                          );
                        } else {
                          Get.snackbar('Error', 'Vehicle not found');
                        }
                      },
                      child: const Text('View Vehicle'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
