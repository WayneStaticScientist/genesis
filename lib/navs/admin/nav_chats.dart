import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';

class NavChats extends StatelessWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const NavChats({super.key, this.triggerKey});

  @override
  Widget build(BuildContext context) {
    // Modern Dark Theme Constants

    return Scaffold(
      appBar: AppBar(
        leading: DrawerButton(
          onPressed: () => triggerKey?.currentState?.openDrawer(),
        ),
        backgroundColor: GTheme.surface(),
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
            onPressed: () {},
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
                color: GTheme.surface().withAlpha(128),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 24),
                itemCount: chatData.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final chat = chatData[index];
                  return _buildChatTile(chat, GTheme.primary);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(Map chat, Color accent) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(chat['avatar']),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            chat['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            chat['time'],
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
                chat['message'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat['unread'] > 0 ? Colors.white : Colors.grey,
                  fontWeight: chat['unread'] > 0
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            if (chat['unread'] > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chat['unread']}',
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
}

// Mock Data
final List<Map<String, dynamic>> chatData = [
  {
    'name': 'Sarah Jenkins',
    'message': 'The presentation is ready for tomorrow\'s meeting!',
    'time': '10:45 AM',
    'unread': 2,
    'avatar': 'https://i.pravatar.cc/150?u=1',
  },
  {
    'name': 'Mike Ross',
    'message': 'Did you see the latest route updates?',
    'time': '9:12 AM',
    'unread': 0,
    'avatar': 'https://i.pravatar.cc/150?u=2',
  },
  {
    'name': 'Design Team',
    'message': 'Alex: I\'ve uploaded the new mockups to the drive.',
    'time': 'Yesterday',
    'unread': 0,
    'avatar': 'https://i.pravatar.cc/150?u=3',
  },
];
