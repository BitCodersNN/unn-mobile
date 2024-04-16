import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/file_functions.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/ui/router.dart';

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
    return SingleChildScrollView(
      child: Column(
        children: [
          TextButton(
            onPressed: () async {
              await clearCacheFolder();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Кэш очищен"),
                  ),
                );
              }
            },
            child: const Text("Очистить кэш"),
          ),
          TextButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Выйти из аккаунта?"),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await clearEverything();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.loadingPage,
                            (route) => false,
                          );
                        }
                      },
                      child: Text(
                        "Выйти",
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Отмена"))
                  ],
                ),
              );
            },
            child: Text(
              "Выйти из аккаунта",
              style: TextStyle(color: theme.colorScheme.error),
            ),
          )
        ],
      ),
    );
  }
}
