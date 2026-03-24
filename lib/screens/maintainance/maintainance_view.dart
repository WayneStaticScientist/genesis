import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/utils/toast.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/models/maintainance_model.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/controllers/maintainance_controller.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final String maintainance_id;
  const MaintenanceDetailScreen({super.key, required this.maintainance_id});

  @override
  State<MaintenanceDetailScreen> createState() =>
      _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  final _maintainanceController = Get.find<MaintainanceController>();
  final _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _maintainanceController.getMantainance(widget.maintainance_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              title: Obx(
                () => _maintainanceController.maintainance.value != null
                    ? Text(
                        _maintainanceController.maintainance.value!.carModel ??
                            'Vehicle Maintenance',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : const SizedBox.shrink(),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.withAlpha(50),
                      const Color(0xFF0F172A),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_car_filled_outlined,
                    size: 80,
                    color: Colors.white.withAlpha(30),
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            if (_maintainanceController.gettingMaintainance.value) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (_maintainanceController.maintainance.value == null) {
              return SliverToBoxAdapter(
                child: Center(
                  child: "Maintainance failed to fetch please try again".text(),
                ),
              );
            }
            final maintenance = _maintainanceController.maintainance.value!;

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHealthSection(maintenance),
                    const SizedBox(height: 24),
                    _buildInfoCard(maintenance),
                    const SizedBox(height: 24),
                    const Text(
                      "Service Description",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        maintenance.issueDetails,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ).sizedBox(width: double.infinity),
                    const SizedBox(height: 24),

                    const Text(
                      "Maintainer",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildMantainerId(maintenance.maintainerId),
                    if (maintenance.approverId != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        "Approver",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildMantainerId(maintenance.approverId),
                    ],
                    const SizedBox(height: 40),

                    // Conditional Action Buttons
                    if (maintenance.status == "Submitted" &&
                        (_userController.user.value?.role == 'manager' ||
                            _userController.user.value?.role == 'admin')) ...[
                      Row(
                        children: [
                          Obx(
                            () =>
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _maintainanceController
                                          .updateMaintainanceStatus(
                                            id: widget.maintainance_id,
                                            accepted: false,
                                          );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      "Reject",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ).visibleIfNot(
                                  _maintainanceController
                                      .updatingMaintainance
                                      .value,
                                ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                _maintainanceController
                                    .updateMaintainanceStatus(
                                      id: widget.maintainance_id,
                                      accepted: true,
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Obx(
                                () =>
                                    _maintainanceController
                                        .updatingMaintainance
                                        .value
                                    ? WhiteLoader()
                                    : const Text(
                                        "Confirm Maintenance",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (maintenance.status == "Approved" &&
                        (_userController.user.value?.role == 'manager' ||
                            _userController.user.value?.role == 'maintainer' ||
                            _userController.user.value?.role == 'admin')) ...[
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                _showCompletionDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Obx(
                                () =>
                                    _maintainanceController
                                        .updatingMaintainance
                                        .value
                                    ? WhiteLoader()
                                    : const Text(
                                        "Mark As Completed",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHealthSection(MaintainanceModel data) {
    final color = _getHealthColor(data.currentHealth);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: data.currentHealth / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  color: color,
                ),
              ),
              Text(
                "${(data.currentHealth).toInt()}%",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Health",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                Text(
                  _getHealthStatus(data.currentHealth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getUrgencyColor(data.urgenceLevel).withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.urgenceLevel,
                  style: TextStyle(
                    color: _getUrgencyColor(data.urgenceLevel),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.status,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(MaintainanceModel data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.pin_drop_outlined,
            "License Plate",
            data.licencePlate,
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildDetailRow(
            Icons.fingerprint,
            "Vehicle ",
            data.carModel ?? 'N/A',
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            "Due Date",
            "${data.dueDate.day}/${data.dueDate.month}/${data.dueDate.year}",
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildDetailRow(
            Icons.payments_outlined,
            "Est. Cost",
            "\$${data.estimatedCosts.toStringAsFixed(2)}",
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMantainerId(dynamic data) {
    if (data == null || data.runtimeType == String) return Container();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.person_4_outlined,
            "FirstName",
            data['firstName'] ?? '',
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildDetailRow(
            Icons.person_4_outlined,
            "LastName",
            data['lastName'] ?? '',
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildDetailRow(
            Icons.person_4_outlined,
            "Email",
            data['email'] ?? "",
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? Colors.greenAccent : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ).constrained(maxWidth: 100),
      ],
    );
  }

  Color _getHealthColor(double health) {
    if (health > 0.7) return Colors.greenAccent;
    if (health > 0.4) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getHealthStatus(double health) {
    if (health > 0.7) return "Excellent";
    if (health > 0.4) return "Fair Condition";
    return "Critical State";
  }

  Color _getUrgencyColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      default:
        return Colors.blueAccent;
    }
  }

  void _handleMaintainanceCompleted() async {
    final response = await _maintainanceController.markAsCompleted(
      _maintainanceController.maintainance.value?.id ?? '',
    );
    if (response) {
      Toaster.showSuccess("mantainance updated success");
    }
  }

  void _showCompletionDialog() {
    Get.defaultDialog(
      title: "Complete",
      content: "Mark maintainance as completed".text(),
      textCancel: "close",
      textConfirm: "yes",
      onConfirm: () {
        Get.back();
        _handleMaintainanceCompleted();
      },
    );
  }
}
