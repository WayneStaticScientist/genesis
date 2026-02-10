import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/models/user_model.dart'; // Ensure this matches your project structure
import 'package:genesis/utils/screen_sizes.dart';
import 'package:genesis/widgets/layouts/driver_card.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:genesis/utils/theme.dart';

class AdminNavDrivers extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavDrivers({super.key, this.triggerKey});

  @override
  State<AdminNavDrivers> createState() => _AdminNavDriversState();
}

class _AdminNavDriversState extends State<AdminNavDrivers> {
  final _refreshController = RefreshController();
  final _driverController = Get.find<UserController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _driverController.fetchDrivers();
  }

  @override
  Widget build(BuildContext context) {
    final isDeskop = MediaQuery.of(context).size.width > ScreenSizes.DESKTOP_W;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () async {
          await _driverController.fetchDrivers();
          _refreshController.refreshCompleted();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // === 1. APP BAR ===
            SliverAppBar(
              floating: true,
              leading: DrawerButton(
                color: Colors.white,
                onPressed: () {
                  widget.triggerKey?.currentState?.openDrawer();
                },
              ).visibleIfNot(isDeskop),
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),

            // === 2. STATS ===
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    _buildMiniStat("Total", "24", Colors.blue),
                    const SizedBox(width: 10),
                    _buildMiniStat("Available", "8", Colors.green),
                    const SizedBox(width: 10),
                    _buildMiniStat("On Trip", "16", Colors.orange),
                  ],
                ),
              ),
            ),

            // === 3. SEARCH ===
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search driver...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ),

            // === 4. DRIVER LIST ===
            Obx(() {
              if (_driverController.loadingDrivers.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final driver = _driverController.drivers[index];
                    return DriverCard(
                      user: driver,
                      onAssign: () => _showAssignTripModal(context, driver),
                    );
                  }, childCount: _driverController.drivers.length),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  void _showAssignTripModal(BuildContext context, User driver) {
    // Shows the assignment dialog/sheet
    Get.bottomSheet(
      AssignTripModal(driver: driver),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(70)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withAlpha(200)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET: Driver Card
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// WIDGET: Assign Trip Modal
// ---------------------------------------------------------------------------
class AssignTripModal extends StatelessWidget {
  final User driver;
  const AssignTripModal({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "New Trip Assignment",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Assigning to ${driver.firstName}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Destination Input
                _buildInputLabel("DESTINATION"),
                TextFormField(
                  decoration: _modernInputDecoration(
                    Icons.map,
                    "Enter destination city/depot",
                  ),
                ),

                const SizedBox(height: 20),

                // Schedule Visualizer
                _buildInputLabel("SCHEDULE"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 12,
                            color: Colors.blue,
                          ),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          const Icon(
                            Icons.circle_outlined,
                            size: 12,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Departure
                            Text(
                              "Departure",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            TextFormField(
                              initialValue: "10:00",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.access_time, size: 18),
                              ),
                            ),
                            const Divider(),
                            // Arrival
                            Text(
                              "Est. Arrival",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            TextFormField(
                              initialValue: "19:00",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.flag_outlined, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Details Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("LOAD TYPE"),
                          TextFormField(
                            initialValue: "Coal",
                            decoration: _modernInputDecoration(
                              Icons.local_shipping,
                              "Type",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("WEIGHT (T)"),
                          TextFormField(
                            initialValue: "30.5",
                            decoration: _modernInputDecoration(
                              Icons.scale,
                              "Tons",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Payment Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(27),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DRIVER PAYMENT",
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Per completed trip",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          initialValue: "700",
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          decoration: InputDecoration(
                            prefixText: "\$ ",
                            prefixStyle: TextStyle(
                              color: Colors.green[800],
                              fontSize: 24,
                            ),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        "Trip Assigned",
                        "Trip successfully queued for ${driver.firstName}",
                        backgroundColor: GTheme.color(),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(20),
                        borderRadius: 10,
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GTheme.color(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: GTheme.color().withOpacity(0.4),
                    ),
                    child: const Text(
                      "CONFIRM ASSIGNMENT",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Colors.grey,
        ),
      ),
    );
  }

  InputDecoration _modernInputDecoration(IconData icon, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[50],
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: GTheme.color(), width: 1.5),
      ),
    );
  }
}
