import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/app_settings_keys.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class AppSettings {
  static bool vibrationEnabled = true;

  static Future<void> load() async {
    final storage = Injector.appInstance.get<StorageService>();
    if (await storage.containsKey(key: AppSettingsKeys.vibrationEnabled)) {
      vibrationEnabled = bool.tryParse(
            (await storage.read(
              key: AppSettingsKeys.vibrationEnabled,
            ))!,
          ) ??
          true;
    }
  }

  static Future<void> save() async {
    final storage = Injector.appInstance.get<StorageService>();
    await storage.write(
      key: AppSettingsKeys.vibrationEnabled,
      value: vibrationEnabled.toString(),
    );
  }
}
