import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/utils/toast.dart';
import 'package:get/get.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/messsage_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:genesis/utils/database_carrier.dart';

class MessagingController extends GetxController {
  RxInt notifications = RxInt(0);
  RxString currentChatUserId = RxString("");
  @override
  void onInit() {
    super.onInit();
    _syncMessages();
  }

  void initializeMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == "message") {
        return _decodeMessage(message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  RxList<MesssageModel> messages = RxList();
  RxBool loadingMessages = RxBool(false);
  void getUserMessages(User user) async {
    final _userController = Get.find<UserController>();
    final me = _userController.user.value;
    if (me == null) return;
    final isar = IsarStatic.isar;
    if (isar == null) return;
    final msgs = isar.messsageModels
        .where()
        .group(
          (q) => q
              .senderIdEqualTo(me.id)
              .and()
              .receiverIdEqualTo(user.id)
              .or()
              .senderIdEqualTo(user.id)
              .and()
              .receiverIdEqualTo(me.id),
        )
        .syncedEqualTo(true)
        .findAll();
    messages.value = msgs;
  }

  RxBool sendingMessage = RxBool(false);
  Future<bool> sendMessage(String content, User receiver) async {
    final isar = IsarStatic.isar;
    if (isar == null) {
      Toaster.showError("Database not initialized");
      return false;
    }
    final _userController = Get.find<UserController>();
    final me = _userController.user.value;
    if (me == null) return false;
    final newMessage = MesssageModel(
      content: content,
      senderId: me.id,
      receiverId: receiver.id,
      timestamp: DateTime.now(),
      id: isar.messsageModels.autoIncrement(),
    );
    final response = await Net.post("/chat", data: newMessage.toJSON());
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    await isar.write((isar) async {
      isar.messsageModels.put(newMessage);
    });
    messages.add(newMessage);
    return true;
  }

  void _decodeMessage(Map<String, dynamic> data) async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    final message = MesssageModel.fromJSON(data);
    await isar.write((isar) async {
      isar.messsageModels.put(message);
    });
    if (currentChatUserId.value == message.senderId) {
      messages.add(message);
      return;
    }
    _syncMessages();
  }

  void _syncMessages() async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    final _userController = Get.find<UserController>();
    final unsyncedMessages = isar.messsageModels
        .where()
        .syncedEqualTo(false)
        .findAll();
    MesssageModel? dataMessage;
    User? user;
    for (var message in unsyncedMessages) {
      final receiver = await _userController.getArgumentedUser(
        message.receiverId,
      );
      final response = await _syncMessage(message, receiver, isar);
      if (response && dataMessage == null) {
        dataMessage = message;
        user = receiver;
      }
    }
    if (user != null && dataMessage != null) {
      Get.snackbar(
        "${user.firstName} ${user.lastName}",
        dataMessage.content.length > 30
            ? "${dataMessage.content.substring(0, 30)}..."
            : dataMessage.content,
      );
    }
    calculateNotiificationSize();
  }

  Future<bool> _syncMessage(
    MesssageModel message,
    User? receiver,
    Isar isar,
  ) async {
    if (receiver == null) return false;
    receiver.lastMessage = message.content;
    receiver.notifications = (receiver.notifications) + 1;
    message.synced = true;
    await isar.write((isar) async {
      isar.messsageModels.put(message);
      isar.users.put(receiver);
    });
    return true;
  }

  void clearUser(User user) async {
    if (messages.isEmpty) return;
    final isar = IsarStatic.isar;
    if (isar == null) return;
    await isar.write((isar) async {
      isar.users.put(user);
    });
    messages.clear();
    getChatUsers();
  }

  RxList<User> chatUsers = RxList();
  void getChatUsers() async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    final users = isar.users.where().findAll();
    chatUsers.value = users;
    calculateNotiificationSize();
  }

  void calculateNotiificationSize() {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    notifications.value = isar.users.where().notificationsProperty().sum();
  }
}
