import 'dart:async';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/widgets/layouts/employee_card.dart';
import 'package:genesis/screens/employees/employees_add.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';

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
      filter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.surface(context),
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

            SliverToBoxAdapter(child: _buildSearchBar()),

            // 4. Employee List
            _buildEmployeeList(),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => EmployeeAddScreen()),
        backgroundColor: GTheme.primary(context),
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
        color: Colors.white,
        onPressed: () {
          widget.triggerKey?.currentState?.openDrawer();
        },
      ),
      backgroundColor: GTheme.primary(context),
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
              colors: [GTheme.primary(context), const Color(0xFF4F46E5)],
            ),
          ),
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
            prefixIcon: Icon(LineIcons.search, color: GTheme.primary(context)),
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

  void filter() {
    _userController.findChats(query: _searchKey);
  }
}
