import 'dart:async';

import 'package:exui/exui.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:genesis/models/user_model.dart'; // Ensure this matches your project structure
import 'package:genesis/utils/screen_sizes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:genesis/screens/pilots/drivers_add.dart';
import 'package:genesis/widgets/layouts/info_layout.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/screens/pilots/drivers_edit.dart';
import 'package:genesis/widgets/layouts/driver_card.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/widgets/layouts/new_trip_modal.dart';
import 'package:genesis/screens/trips/trips_details_screen.dart';

class AdminNavDrivers extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavDrivers({super.key, this.triggerKey});

  @override
  State<AdminNavDrivers> createState() => _AdminNavDriversState();
}

class _AdminNavDriversState extends State<AdminNavDrivers> {
  Timer? _debounceTimer;
  String _searchKey = '';
  final _refreshController = RefreshController();
  final _driverController = Get.find<UserController>();
  final _statsController = Get.find<StatsController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _driverController.fetchDrivers();
    _initDebounceTimer();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
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
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => Get.to(() => AdminAddDriver()),
                ),
              ],
            ),

            // === 2. STATS ===
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    _buildMiniStat(
                      "Total",
                      _statsController.stats.value?.totalDriversInSystem
                              .toString() ??
                          "",
                      Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    _buildMiniStat("Available", "0", Colors.green),
                    const SizedBox(width: 10),
                    _buildMiniStat("On Trip", "0", Colors.orange),
                  ],
                ),
              ),
            ).visibleIfNotNull(_statsController.stats),

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
              if (_driverController.loadingDrivers.value &&
                  _driverController.drivers.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (_driverController.drivers.isEmpty) {
                return SliverFillRemaining(
                  child: InfoLayout(
                    label: "No Drivers Found",
                    icon: Icon(
                      LineIcons.alternateRedo,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ).center(),
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
                    ).onTap(
                      () => Get.to(() => AdminEditDriver(driver: driver)),
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
    if (driver.trip != null) {
      Get.to(() => TripDetailsScreen(tripId: driver.trip!.id));
      return;
    }
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

  void _initDebounceTimer() {
    _debounceTimer = Timer.periodic(Duration(milliseconds: 700), _filterSearch);
  }

  void _filterSearch(Timer timer) {
    if (_searchController.text != _searchKey) {
      setState(() {
        _searchKey = _searchController.text;
      });
      fetchDrivers(1);
    }
  }

  void fetchDrivers(int i) {
    _driverController.fetchDrivers(page: i, search: _searchKey);
  }
}

// ---------------------------------------------------------------------------
// WIDGET: Driver Card
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// WIDGET: Assign Trip Modal
// ---------------------------------------------------------------------------
