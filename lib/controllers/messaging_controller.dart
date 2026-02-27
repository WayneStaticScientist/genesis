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
  @override
  void onInit() {
    super.onInit();
  }

  void initializeMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
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
}
