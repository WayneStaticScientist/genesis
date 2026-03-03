import 'package:get/get.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/messsage_model.dart';
import 'package:genesis/utils/database_carrier.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:genesis/services/genesis_notification_handler.dart';

class MessagingController extends GetxController {
  RxInt notifications = RxInt(0);
  RxString currentChatUserId = RxString("");
  @override
  void onInit() {
    super.onInit();
    _syncMessages();
  }

  void initializeMessaging() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == "message") {
        return _decodeMessage(message.data, message);
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
    messages.value = msgs.reversed.toList();
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
    final index = chatUsers.indexOf((user) => user.id == receiver.id);
    if (index > 0) {
      chatUsers[index].lastMessage = content;
      chatUsers.refresh();
    }
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
      receiver.lastMessage = content;
      isar.users.put(receiver);
    });
    messages.insert(0, newMessage);
    return true;
  }

  void _decodeMessage(Map<String, dynamic> data, RemoteMessage rmessage) async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    final message = MesssageModel.fromJSON(data);
    message.synced = false;
    final isarUser = isar.users.where().idEqualTo(message.senderId).findFirst();

    await isar.write((isar) async {
      isar.messsageModels.put(message);
      if (isarUser != null) {
        isarUser.lastMessage = message.content;
        isar.users.put(isarUser);
      }
    });
    final index = chatUsers.indexOf((user) => user.id == message.senderId);
    if (index > 0) {
      chatUsers[index].lastMessage = message.content;
      chatUsers.refresh();
    }

    if (currentChatUserId.value == message.senderId) {
      messages.insert(0, message);
      messages.refresh();
      Get.snackbar("Inchat Message", "check your last message");
      return;
    }
    GenesisNotificationHandler.showNotification(rmessage);
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
    for (var message in unsyncedMessages) {
      final senderId = await _userController.getArgumentedUser(
        message.senderId,
      );
      final response = await _syncMessage(message, senderId, isar);
      if (response && dataMessage == null) {
        dataMessage = message;
      }
    }
    getChatUsers();
  }

  Future<bool> _syncMessage(
    MesssageModel message,
    User? senderId,
    Isar isar,
  ) async {
    if (senderId == null) return false;
    senderId.lastMessage = message.content;
    senderId.notifications = (senderId.notifications) + 1;
    message.synced = true;
    await isar.write((isar) async {
      isar.messsageModels.put(message);
      isar.users.put(senderId);
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

  void calculateNotiificationSize() async {
    final isar = IsarStatic.isar;
    if (isar == null) return;
    int size = await isar.users.where().notificationsProperty().sumAsync();
    notifications.value = size;
  }

  Future<bool> deleteChats(List<String> selectedChats) async {
    final _userController = Get.find<UserController>();
    final isar = IsarStatic.isar;
    if (isar == null || _userController.user.value == null) {
      Toaster.showError("Database not initialized ! Try again ");
      return false;
    }
    try {
      for (final user in selectedChats) {
        await isar.write((isar) async {
          isar.users.deleteAll(selectedChats);
          isar.messsageModels
              .where()
              .group(
                (q) => q
                    .senderIdEqualTo(user)
                    .and()
                    .receiverIdEqualTo(_userController.user.value!.id),
              )
              .or()
              .group(
                (q) => q
                    .senderIdEqualTo(_userController.user.value!.id)
                    .and()
                    .receiverIdEqualTo(user),
              )
              .deleteAll();
        });
      }
      Toaster.showSuccess("deletion was succefull");
      getChatUsers();
      return true;
    } catch (e) {
      Toaster.showError("Error : $e");
      return false;
    }
  }
}
