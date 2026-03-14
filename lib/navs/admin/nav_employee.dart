import 'dart:async';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/layouts/employee_card.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// --- SCREEN IMPLEMENTATION ---
class AdminNavEmployees extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavEmployees({super.key, this.triggerKey});

  @override
  State<AdminNavEmployees> createState() => _AdminNavEmployeesState();
}

class _AdminNavEmployeesState extends State<AdminNavEmployees> {
  final RefreshController _refreshController = RefreshController();
  final TextEditingController _searchController = TextEditingController();
  String _searchKey = '';
  Timer? _debounceTimer;

  // Mocking the controllers based on your structure
  final _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    filter();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchKey = value);
      // _userController.fetchEmployees(search: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.surface(),
      body: SmartRefresher(
        controller: _refreshController,
        header: const WaterDropMaterialHeader(
          backgroundColor: Color(0xFF6366F1),
        ),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          _refreshController.refreshCompleted();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Dynamic Modern App Bar
            _buildSliverAppBar(),

            // 2. Statistics Row (Admins, Managers, Drivers)
            SliverToBoxAdapter(child: _buildQuickStats()),

            // 3. Search Bar with Filter
            SliverToBoxAdapter(child: _buildSearchBar()),

            // 4. Employee List
            _buildEmployeeList(),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEmployeeSheet(context),
        backgroundColor: GTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "New Staff",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      leading: DrawerButton(
        onPressed: () {
          widget.triggerKey?.currentState?.openDrawer();
        },
      ),
      backgroundColor: GTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "Workforce",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [GTheme.primary, const Color(0xFF4F46E5)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LineIcons.bell, color: Colors.white),
          onPressed: () {},
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Row(
        children: [
          _statItem("Admins", "04", Colors.indigo),
          const SizedBox(width: 12),
          _statItem("Managers", "12", Colors.amber),
          const SizedBox(width: 12),
          _statItem("Drivers", "48", Colors.teal),
        ],
      ),
    );
  }

  Widget _statItem(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color..withAlpha(35), width: 1),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withAlpha(0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: "Find employee by name or email...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(LineIcons.search, color: GTheme.primary),
            suffixIcon: Icon(LineIcons.filter, color: Colors.grey.shade400),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return Obx(() {
      if (_userController.findingChats.value) {
        return SliverFillRemaining(child: MaterialLoader().center());
      }
      if (_userController.foundChats.isEmpty) {
        return SliverFillRemaining(child: "no employees found".text());
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final user = _userController.foundChats[index];
            return EmployeeCard(user: user);
          }, childCount: _userController.foundChats.length),
        ),
      );
    });
  }

  void _showAddEmployeeSheet(BuildContext context) {
    Get.bottomSheet(
      const AddEmployeeModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void filter() {
    _userController.findChats(query: _searchKey);
  }
}

// --- SUB-WIDGET: EMPLOYEE CARD ---

// --- SUB-WIDGET: ADD EMPLOYEE MODAL ---
class AddEmployeeModal extends StatefulWidget {
  const AddEmployeeModal({super.key});

  @override
  State<AddEmployeeModal> createState() => _AddEmployeeModalState();
}

class _AddEmployeeModalState extends State<AddEmployeeModal> {
  String selectedRole = 'Driver';
  final List<String> roles = ['Admin', 'Manager', 'Driver'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "Add New Staff",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Enter employee details to grant access",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 25),

          // Role Selector
          const Text(
            "Select Role",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: roles.map((role) {
              bool isSelected = selectedRole == role;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedRole = role),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? GTheme.primary : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? GTheme.primary
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        role,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          _buildField("First Name", LineIcons.user),
          const SizedBox(height: 15),
          _buildField("Last Name", LineIcons.userCircle),
          const SizedBox(height: 15),
          _buildField("Email Address", LineIcons.envelope),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: GTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildField(String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(icon, size: 20, color: Colors.grey),
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
