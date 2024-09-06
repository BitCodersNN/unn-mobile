import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/file_functions.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/ui/widgets/adaptive_dialog_action.dart';
import 'package:unn_mobile/ui/widgets/adaptive_switch.dart';

class SettingsScreenView extends StatelessWidget {
  const SettingsScreenView({super.key});

  Future<void> clearEverything() async {
    await Injector.appInstance.get<StorageService>().clear();
    await DefaultCacheManager().emptyCache();
    clearCacheFolder();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Expanded(
                    child: Text('Вибрация'),
                  ),
                  const SizedBox(width: 6),
                  AddaptiveSwtich(
                    startPosition: AppSettings.vibrationEnabled,
                    enabled: true,
                    onChanged: (bool value) async {
                      AppSettings.vibrationEnabled = value;
                      await AppSettings.save();
                    },
                  ),
                ],
              ),
            ),
            Divider(
              color: theme.colorScheme.outlineVariant,
            ),
            TextButton(
              onPressed: () async {
                await clearCacheFolder();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Кэш очищен'),
                    ),
                  );
                }
              },
              child: const Text('Очистить кэш'),
            ),
            TextButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog.adaptive(
                    title: const Text('Выйти из аккаунта?'),
                    actions: [
                      AdaptiveDialogAction(
                        onPressed: () async {
                          await clearEverything();
                          if (context.mounted) {
                            // TODO:
                            // Navigator.of(context).pushNamedAndRemoveUntil(
                            //   Routes.loadingPage,
                            //   (route) => false,
                            // );
                          }
                        },
                        child: Text(
                          'Выйти',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                      AdaptiveDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Отмена'),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Выйти из аккаунта',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
