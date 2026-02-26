import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class MessagingController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  void initializeMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }
}
