import 'package:genesis/controllers/maintainance_controller.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/widgets/displays/error_widget.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/screens/maintainance/maintainance_add.dart';
import 'package:genesis/widgets/actions/filter_chip.dart';
import 'package:genesis/widgets/layouts/maintanance_card.dart';

class AdminNavMaintenance extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;

  const AdminNavMaintenance({super.key, this.triggerKey});

  @override
  State<AdminNavMaintenance> createState() => _AdminNavMaintenanceState();
}

class _AdminNavMaintenanceState extends State<AdminNavMaintenance> {
  final _maintainanceController = Get.find<MaintainanceController>();
  final _userController = Get.find<UserController>();
  String _status = '';
  @override
  void initState() {
    super.initState();
    filterResults();
  }

  @override
  Widget build(BuildContext context) {
    // Theme references for cleaner code
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // === MODERN GLASS-STYLE HEADER ===
          SliverAppBar(
            leading: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(30),
              child: DrawerButton(
                color: Colors.white,
                onPressed: () {
                  widget.triggerKey?.currentState?.openDrawer();
                },
              ),
            ),
            expandedHeight: 140, // Reduced for a sleeker profile
            floating: true,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground,
              ],
              titlePadding: const EdgeInsetsDirectional.only(
                start: 24,
                bottom: 16,
              ),
              centerTitle: false,
              title: Text(
                "Maintenance Vault",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Subtle design element (abstract circle)
                  Positioned(
                    right: -50,
                    top: -20,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withAlpha(30),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Get.to(() => AdminAddMaintenance()),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ],
          ),

          // === REFINED FILTER SECTION ===
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: "Operational Overview".text(
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      GFilterChip(
                        label: "All Tasks",
                        isSelected: _status.isEmpty,
                      ).onTap(() {
                        setState(() {
                          _status = "";
                        });
                        filterResults();
                      }),
                      GFilterChip(
                        label: "Critical",
                        isSelected: _status == "Critical",
                        color: Colors.redAccent,
                      ).onTap(() {
                        setState(() {
                          _status = "Critical";
                        });
                        filterResults();
                      }),
                      GFilterChip(
                        label: "Routine",
                        isSelected: _status == "Routine",
                        color: Colors.teal.shade700,
                      ).onTap(() {
                        setState(() {
                          _status = "Routine";
                        });
                        filterResults();
                      }),
                      GFilterChip(
                        label: "Due Soon",
                        isSelected: _status == "Due Soon",
                        color: Colors.deepPurple.shade700,
                      ).onTap(() {
                        setState(() {
                          _status = "Due Soon";
                        });
                        filterResults();
                      }),
                      GFilterChip(
                        label: "Completed",
                        isSelected: _status == "Completed",
                        color: Colors.green,
                      ).onTap(() {
                        setState(() {
                          _status = "Completed";
                        });
                        filterResults();
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // === DYNAMIC CONTENT AREA ===
          Obx(() {
            // Loading State
            if (_maintainanceController.loadingMaintainances.value &&
                _maintainanceController.maintainances.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: MaterialLoader()),
              );
            }

            // Error State
            if (_maintainanceController
                .mantainanceFetchingStatus
                .value
                .isNotEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: MaterialErrorWidget(
                    label:
                        _maintainanceController.mantainanceFetchingStatus.value,
                  ),
                ),
              );
            }

            // Empty State
            if (_maintainanceController.maintainances.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_motion_rounded,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      "No maintenance tasks recorded".text(
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              );
            }

            // List State
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GMaintananceCard(
                      task: _maintainanceController.maintainances[index],
                      user: _userController.user.value!,
                    ),
                  ),
                  childCount: _maintainanceController.maintainances.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void filterResults() {
    _maintainanceController.fetchAllMaintainances(status: _status);
  }
}
