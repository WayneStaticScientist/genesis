import 'dart:async';

import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis/utils/theme.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:genesis/navs/admin/fleet_tracking.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/controllers/socket_controller.dart';
import 'package:genesis/widgets/layouts/vehicle_cards.dart';
import 'package:genesis/screens/vehicles/vehicles_add.dart';
import 'package:genesis/widgets/displays/error_widget.dart';
import 'package:genesis/widgets/layouts/main_stat_card.dart';
import 'package:genesis/controllers/vehicle_controller.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';

class AdminNavVehicles extends StatefulWidget {
  const AdminNavVehicles({super.key});

  @override
  State<AdminNavVehicles> createState() => _AdminNavVehiclesState();
}

class _AdminNavVehiclesState extends State<AdminNavVehicles> {
  final _refreshController = RefreshController();
  final _statsController = Get.find<StatsController>();
  final _socketController = Get.find<SocketController>();
  final _vehicleController = Get.find<VehicleControler>();
  late Timer _tickerTimer;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  // Mock Data for the "Wow" factor
  @override
  void initState() {
    super.initState();
    _vehicleController.fetchAllVehicles();
    _createTicker();
  }

  @override
  void dispose() {
    _tickerTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      onRefresh: () async {
        await _vehicleController.fetchAllVehicles(search: searchQuery.trim());
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        if (_vehicleController.totalPages.value <=
            _vehicleController.page.value) {
          _refreshController.loadNoData();
          return;
        }
        await _vehicleController.fetchAllVehicles(
          search: searchQuery.trim(),
          page: _vehicleController.page.value + 1,
        );
        _refreshController.loadComplete();
      },
      controller: _refreshController,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // === PREMIUM HEADER ===
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).colorScheme.primary,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
            ),
            backgroundColor: GTheme.color(),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: "Fleet Management".text(
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(25),
                  child: IconButton(
                    onPressed: () => Get.to(() => AdminAddVehicle()),
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // === METRIC OVERVIEW CARDS ===
          Obx(
            () => _statsController.stats.value != null
                ? SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          GMainStatCard(
                            title: "Total Fleet",
                            value: _statsController
                                .stats
                                .value!
                                .totalVehiclesInSystem
                                .toString(),
                            icon: Icons.car_repair,
                            color: Colors.blue,
                          ),
                          GMainStatCard(
                            title: "Active Now",
                            value: "0",
                            icon: Icons.location_on,
                            color: Colors.green,
                          ),
                          GMainStatCard(
                            title: "Maintenance",
                            value: _statsController
                                .stats
                                .value!
                                .totalMaintenanceCount
                                .toString(),
                            icon: Icons.build_circle,
                            color: Colors.orange,
                          ),
                          GMainStatCard(
                            title: "costs",
                            value:
                                "\$${_statsController.stats.value!.totalMaintainanceCost}",
                            icon: Icons.alternate_email,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverToBoxAdapter(),
          ),

          // === SEARCH & FILTER ===
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: GTheme.color(),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.search, color: Colors.grey),
                          hintText: "Search plate or model...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GTheme.color(),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.filter_list, color: GTheme.reverse()),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (_vehicleController.loadingVehicles.value &&
                _vehicleController.vehicles.isEmpty) {
              return SliverFillRemaining(child: MaterialLoader().center());
            }
            if (_vehicleController.vehicleFetchingStatus.value.isNotEmpty) {
              return SliverFillRemaining(
                child: MaterialErrorWidget(
                  label: _vehicleController.vehicleFetchingStatus.value,
                ).center(),
              );
            }
            if (_vehicleController.vehicles.isEmpty &&
                !_vehicleController.loadingVehicles.value) {
              return SliverFillRemaining(
                child: "No results found for vehicles".text(),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => GVehicleCard(
                    vehicle: _vehicleController.vehicles[index],
                    onTrackLive: () {
                      _socketController.listenId.value =
                          _vehicleController.vehicles[index].id!;
                      Get.to(() => FleetTrackingScreen());
                    },
                  ),
                  childCount: _vehicleController.vehicles.length,
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ClassicFooter(),
        ],

        // === VEHICLE LIST ===
      ),
    );
  }

  void _createTicker() {
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (searchQuery.trim() != _searchController.text.trim()) {
        setState(() {
          searchQuery = _searchController.text;
        });
        _vehicleController.fetchAllVehicles(search: searchQuery.trim());
      }
    });
  }
}
