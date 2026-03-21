import 'package:genesis/models/messsage_model.dart';
import 'package:genesis/models/notification_model.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:genesis/models/user_model.dart';
import 'package:path_provider/path_provider.dart';

class IsarStatic {
  static Isar? isar;
  static Future<void> init() async {
    if (isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      schemas: [UserSchema, MesssageModelSchema, NotificationModelSchema],
      directory: dir.path,
    );
  }
}
