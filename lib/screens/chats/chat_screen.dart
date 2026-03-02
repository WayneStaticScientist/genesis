import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/messsage_model.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/controllers/messaging_controller.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  const ChatScreen({required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isSending = false;
  final _messagingController = Get.find<MessagingController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.user.notifications = 0;
    _messagingController.currentChatUserId.value = widget.user.id;
    _messagingController.getUserMessages(widget.user);
  }

  @override
  void dispose() {
    _messagingController.currentChatUserId.value = '';
    _messagingController.clearUser(widget.user);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      Toaster.showError("Message cannot be empty");
      return;
    }
    setState(() {
      _isSending = true;
    });
    final response = await _messagingController.sendMessage(
      _messageController.text.trim(),
      widget.user,
    );
    if (!mounted) return;
    setState(() {
      _isSending = false;
    });
    if (!response) {
      return;
    }
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTheme.surface(),
        elevation: 0,
        leadingWidth: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: Text(
                    widget.user.firstName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: GTheme.primary,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: GTheme.surface(), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.user.firstName} ${widget.user.lastName}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ).constrained(maxWidth: 120),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ).constrained(maxWidth: 110),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages
          Obx(
            () => ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messagingController.messages.length,
              itemBuilder: (context, index) {
                final msg = _messagingController.messages[index];
                return _buildMessageBubble(msg, GTheme.primary);
              },
            ),
          ).expanded1,

          // Input Area
          _buildInputArea(GTheme.surface(), GTheme.primary),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MesssageModel msg, Color accent) {
    bool isMe = (msg.receiverId == widget.user.id);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? accent : const Color(0xFF1C2027),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.grey.shade200,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  GenesisDate.getLastSeen(msg.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(Color surface, Color accent) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: Colors.white.withAlpha(30))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withAlpha(30)),
              ),
              child: TextField(
                enabled: !_isSending,
                controller: _messageController,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: "Message...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withAlpha(77), // 30% alpha of accent color
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isSending
                  ? WhiteLoader()
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
