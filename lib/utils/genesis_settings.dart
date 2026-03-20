import 'package:get_storage/get_storage.dart';

class GenesisSettings {
  bool isDarkMode;
  bool isSystemThemeMode;
  bool biometricLockScreen;
  GenesisSettings({
    required this.isDarkMode,
    required this.isSystemThemeMode,
    required this.biometricLockScreen,
  });
  factory GenesisSettings.fromMap(dynamic data) {
    return GenesisSettings(
      isDarkMode: data['isDarkMode'] ?? false,
      isSystemThemeMode: data['isSystemThemeMode'] ?? true,
      biometricLockScreen: data['biometricLockScreen'] ?? false,
    );
  }
  toMap() {
    return {
      'isDarkMode': isDarkMode,
      'isSystemThemeMode': isSystemThemeMode,
      'biometricLockScreen': biometricLockScreen,
    };
  }

  writeSettings() {
    GetStorage storage = GetStorage();
    storage.write("genesis_settings", toMap());
  }

  factory GenesisSettings.readSettings() {
    GetStorage storage = GetStorage();
    final data = storage.read("genesis_settings") ?? {};
    return GenesisSettings.fromMap(data);
  }
}
