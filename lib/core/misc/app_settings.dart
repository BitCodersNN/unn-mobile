import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/app_settings_keys.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class AppSettings {
  static bool vibrationEnabled = true;
  static int initialPage = 0;

  static Future<void> load() async {
    vibrationEnabled = await _readValue(
      AppSettingsKeys.vibrationEnabled,
      defaultValue: true,
      parser: (val) => bool.tryParse(val),
    );
    initialPage = await _readValue(
      AppSettingsKeys.initialPage,
      defaultValue: 0,
      parser: (val) => int.tryParse(val),
    );
  }

  static Future<T> _readValue<T>(
    key, {
    required T? Function(String val) parser,
    required T defaultValue,
  }) async {
    final storage = Injector.appInstance.get<StorageService>();
    if (await storage.containsKey(key: key)) {
      return parser(await storage.read(key: key) ?? '') ?? defaultValue;
    }
    return defaultValue;
  }

  static Future<void> save() async {
    final storage = Injector.appInstance.get<StorageService>();
    await storage.write(
      key: AppSettingsKeys.vibrationEnabled,
      value: vibrationEnabled.toString(),
    );
    await storage.write(
      key: AppSettingsKeys.initialPage,
      value: initialPage.toString(),
    );
  }
}
