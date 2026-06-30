import 'dart:async';

import 'package:genesis/utils/bool_utils.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:genesis/utils/theme.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:genesis/navs/admin/fleet_tracking.dart';
import 'package:genesis/widgets/layouts/info_layout.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/controllers/socket_controller.dart';
import 'package:genesis/widgets/layouts/vehicle_cards.dart';
import 'package:genesis/screens/vehicles/vehicles_add.dart';
import 'package:genesis/widgets/displays/error_widget.dart';
import 'package:genesis/widgets/layouts/main_stat_card.dart';
import 'package:genesis/controllers/vehicle_controller.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';

class AdminNavVehicles extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;

  const AdminNavVehicles({super.key, this.triggerKey});

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
    final isDark = GTheme.isDark(context);

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
            expandedHeight: 140,
            floating: true,
            pinned: true,
            leading: DrawerButton(
              color: Colors.white,
              onPressed: () {
                widget.triggerKey?.currentState?.openDrawer();
              },
            ).visibleIf(widget.triggerKey != null),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
            ),
            backgroundColor: GTheme.color(context),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GTheme.primary(context),
                      GTheme.primary(context).withBlue(220),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fleet Management",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Track, manage and optimize vehicle performance",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: () => Get.to(() => AdminAddVehicle()),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // === METRIC OVERVIEW CARDS ===
          Obx(
            () => _statsController.stats.value != null
                ? SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          GMainStatCard(
                            title: "Total Fleet",
                            value: _statsController
                                .stats
                                .value!
                                .totalVehiclesInSystem
                                .toString(),
                            icon: Icons.directions_car_filled_rounded,
                            color: Colors.blue,
                          ),
                          GMainStatCard(
                            title: "Active Now",
                            value: _statsController.stats.value!.activeVehicles
                                .toStringAsFixed(0),
                            icon: Icons.sensors_rounded,
                            color: Colors.green,
                          ),
                          GMainStatCard(
                            title: "In Service",
                            value: _statsController
                                .stats
                                .value!
                                .inServiceVehicles
                                .toStringAsFixed(0),
                            icon: Icons.build_circle_rounded,
                            color: Colors.orange,
                          ),
                          GMainStatCard(
                            title: "Total Costs",
                            value:
                                "\$${_statsController.stats.value!.totalMaintainanceCost.toStringAsFixed(0)}",
                            icon: Icons.monetization_on_rounded,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SliverToBoxAdapter(),
          ),

          // === SEARCH & FILTER ===
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: GTheme.emmense(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark.lord(
                            Colors.white12,
                            Colors.black.withAlpha(5),
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.plusJakartaSans(
                          color: GTheme.reverse(context),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.search_rounded,
                            color: Colors.grey.shade400,
                          ),
                          hintText: "Search plate or model...",
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GTheme.emmense(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark.lord(
                          Colors.white12,
                          Colors.black.withAlpha(5),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: GTheme.reverse(context),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === VEHICLE LIST ===
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
                child: InfoLayout(
                  label: "No Vehicles Found",
                  icon: Icon(
                    LineIcons.alternateRedo,
                    size: 32,
                    color: Colors.grey,
                  ),
                ).center(),
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
          const ClassicFooter(),
        ],
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
