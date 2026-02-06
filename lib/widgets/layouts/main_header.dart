import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/layouts/avatar_icon.dart';
import 'package:get/get.dart';

class GMainHeader extends StatefulWidget {
  const GMainHeader({super.key});

  @override
  State<GMainHeader> createState() => _GMainHeaderState();
}

class _GMainHeaderState extends State<GMainHeader> {
  final _userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      color: GTheme.surface(), // Matches background
      child: Row(
        children: [
          DrawerButton(),
          // Search Bar
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: GTheme.color(),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search for vehicles, drivers...",
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
          24.gapWidth,
          // Actions
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
          ),
          16.gapWidth,
          Obx(
            () =>
                AvatarIcon(name: _userController.user.value?.firstName ?? 'U'),
          ),
        ],
      ),
    );
  }
}
