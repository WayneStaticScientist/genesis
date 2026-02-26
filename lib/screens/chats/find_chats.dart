import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/screens/chats/chat_screen.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:get/get.dart';

class FindChatsScreen extends StatefulWidget {
  const FindChatsScreen({super.key});

  @override
  State<FindChatsScreen> createState() => _FindChatsScreenState();
}

class _FindChatsScreenState extends State<FindChatsScreen> {
  final _userController = Get.find<UserController>();
  String _searchKey = '';
  @override
  void initState() {
    super.initState();
    filterResults();
  }

  void filterResults() {
    _userController.findChats(query: _searchKey, page: 1);
  }

  @override
  Widget build(BuildContext context) {
    // Modern Dark Theme Constants
    const Color accentBlue = Color(0xFF2563EB);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTheme.surface(),
        elevation: 0,
        title: const Text(
          'Find People',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: GTheme.surface(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(27)),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: GTheme.surface().withAlpha(128),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Obx(() {
                if (_userController.findingChats.value &&
                    _userController.foundChats.isEmpty) {
                  return MaterialLoader().center();
                }
                if (_userController.foundChats.isEmpty) {
                  return "No users found".text().center();
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  itemCount: _userController.foundChats.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final chat = _userController.foundChats[index];
                    return _buildChatTile(chat, accentBlue);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(User chat, Color accent) {
    return ListTile(
      onTap: () => Get.to(() => ChatScreen()),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(radius: 28, child: chat.firstName[0].text()),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${chat.firstName} ${chat.lastName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            chat.role.toUpperCase(),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                chat.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
