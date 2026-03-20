import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/screens/chats/find_chats.dart';
import 'package:genesis/screens/chats/chat_screen.dart';
import 'package:genesis/controllers/messaging_controller.dart';

class NavChats extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const NavChats({super.key, this.triggerKey});

  @override
  State<NavChats> createState() => _NavChatsState();
}

class _NavChatsState extends State<NavChats> {
  List<String> selectedChats = List.empty(growable: true);
  final _messagesController = Get.find<MessagingController>();
  @override
  void initState() {
    _messagesController.getChatUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Modern Dark Theme Constants

    return Scaffold(
      appBar: AppBar(
        leading: DrawerButton(
          onPressed: () => widget.triggerKey?.currentState?.openDrawer(),
        ),
        backgroundColor: GTheme.surface(context),
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 28),
            onPressed: () => Get.to(() => const FindChatsScreen()),
          ),
          if (selectedChats.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedChats,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: GTheme.surface(context).withAlpha(128),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Obx(() {
                if (_messagesController.chatUsers.isEmpty) {
                  return "No chats , start conversation".text().center();
                }
                return ListView.separated(
                  itemCount: _messagesController.chatUsers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final chat = _messagesController.chatUsers[index];
                    return _buildChatTile(chat, GTheme.primary(context));
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
    bool isInList = selectedChats.contains(chat.id);
    return ListTile(
      onLongPress: () {
        if (!isInList) {
          setState(() {
            selectedChats.add(chat.id);
          });
        }
      },
      tileColor: isInList ? GTheme.primary(context) : null,
      onTap: () {
        if (selectedChats.isEmpty) {
          Get.to(() => ChatScreen(user: chat));
          return;
        }
        setState(() {
          if (isInList) {
            selectedChats.remove(chat.id);
          } else {
            selectedChats.add(chat.id);
          }
        });
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(radius: 28, child: "${chat.firstName[0]}".text()),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${chat.firstName} ${chat.lastName}",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ).constrained(maxWidth: 140),
          Text("-", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat.notifications > 0 ? null : Colors.grey,
                  fontWeight: chat.notifications > 0
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            if (chat.notifications > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chat.notifications}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const Icon(Icons.done_all, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  void _deleteSelectedChats() {
    Get.defaultDialog(
      title: "Delete Selected Chats",
      content: "Messages and the contact will be deleted".text(),
      textCancel: "close",
      textConfirm: "delete",
      onConfirm: () async {
        Get.back();
        final response = await _messagesController.deleteChats(selectedChats);
        if (response && mounted) {
          setState(() {
            selectedChats.clear();
          });
        }
      },
    );
  }
}
