import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/messsage_model.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/controllers/messaging_controller.dart';
import 'package:genesis/services/network_adapter.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  const ChatScreen({required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isSending = false;
  PlatformFile? _selectedFile;
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

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedFile == null) {
      Toaster.showError("Message cannot be empty");
      return;
    }
    setState(() {
      _isSending = true;
    });

    String? fileUrl;
    String? fileName;
    String? fileType;

    if (_selectedFile != null) {
      fileName = _selectedFile!.name;
      fileType = _selectedFile!.extension;

      final uploadRes = await Net.uploadFile(
        "/upload", // assuming standard upload endpoint
        _selectedFile!.path!,
        fileName: fileName,
      );
      if (uploadRes.hasError) {
        Toaster.showError("Failed to upload file: ${uploadRes.response}");
        setState(() {
          _isSending = false;
        });
        return;
      }

      if (uploadRes.body is Map && uploadRes.body['url'] != null) {
        fileUrl = uploadRes.body['url'];
      } else if (uploadRes.body is String) {
        fileUrl = uploadRes.body;
      } else if (uploadRes.body is Map && uploadRes.body['fileUrl'] != null) {
        fileUrl = uploadRes.body['fileUrl'];
      } else {
        fileUrl = uploadRes.body.toString();
      }
    }

    final response = await _messagingController.sendMessage(
      _messageController.text.trim(),
      widget.user,
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileType,
    );
    if (!mounted) return;
    setState(() {
      _isSending = false;
    });
    if (!response) {
      return;
    }
    _messageController.clear();
    _clearFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTheme.surface(context),
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
                  backgroundColor: GTheme.primary(context),
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
                      border: Border.all(
                        color: GTheme.surface(context),
                        width: 2,
                      ),
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
                return _buildMessageBubble(msg, GTheme.primary(context));
              },
            ),
          ).expanded1,

          // Input Area
          _buildInputArea(GTheme.surface(context), GTheme.primary(context)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MesssageModel msg, Color accent) {
    bool isMe = (msg.receiverId == widget.user.id);
    bool isImage = false;
    if (msg.fileType != null) {
      final ext = msg.fileType!.toLowerCase();
      isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
    }

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
            if (msg.fileUrl != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withAlpha(50)
                      : Colors.grey.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: isImage
                    ? Image.network(
                        msg.fileUrl!.startsWith('http')
                            ? msg.fileUrl!
                            : '${Net.url}${msg.fileUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                              ),
                            ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.insert_drive_file,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                msg.fileName ?? 'Document',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            if (msg.content.isNotEmpty)
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
      child: Column(
        children: [
          if (_selectedFile != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(30)),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedFile!.extension?.toLowerCase() == 'jpg' ||
                            _selectedFile!.extension?.toLowerCase() == 'png' ||
                            _selectedFile!.extension?.toLowerCase() == 'jpeg'
                        ? Icons.image
                        : Icons.insert_drive_file,
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFile!.name,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                    onPressed: _clearFile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
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
                        color: accent.withAlpha(77),
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
        ],
      ),
    );
  }
}
