// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_version.dart';
import 'package:unn_mobile/core/viewmodels/main_page/settings/settings_screen_view_model.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';

class SettingsScreenView extends StatelessWidget {
  final int? bottomRouteIndex;

  const SettingsScreenView({super.key, this.bottomRouteIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        forceMaterialTransparency: true,
        leading: getSubpageLeading(bottomRouteIndex),
      ),
      body: BaseView<SettingsScreenViewModel>(
        builder: (context, model, _) => Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  ...ListTile.divideTiles(
                    context: context,
                    tiles: [
                      SwitchListTile.adaptive(
                        title: const Text('Вибрация'),
                        value: model.vibrationEnabled,
                        onChanged: (value) {
                          model.vibrationEnabled = value;
                        },
                      ),
                      SwitchListTile.adaptive(
                        title: const Text('Сбор телеметрии'),
                        value: model.analyticsEnabled,
                        onChanged: (value) {
                          model.analyticsEnabled = value;
                        },
                      ),
                      ListTile(
                        title: const Text('Начальный экран'),
                        trailing: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            model.initialScreenName,
                            style: const TextStyle(fontSize: 16),
                            softWrap: false,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        onTap: () async {
                          await _showScreenChoiceModal(context, model);
                        },
                      ),
                      ListTile(
                        title: const Text('Очистить кэш'),
                        onTap: () async {
                          await model.clearCache();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Кэш очищен'),
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('Выйти из аккаунта'),
                        onTap: () async {
                          if (context.mounted) {
                            final result = await showOkCancelAlertDialog(
                              context: context,
                              title: 'Выйти из аккаунта?',
                              okLabel: 'Выйти',
                              cancelLabel: 'Отмена',
                              isDestructiveAction: true,
                            );

                            if (result == OkCancelResult.ok &&
                                context.mounted) {
                              await model.logout();
                              if (context.mounted) {
                                GoRouter.of(context).go(loadingPageRoute);
                              }
                            }
                          }
                        },
                        textColor: theme.colorScheme.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Align(
              alignment: Alignment.center,
              child: FutureBuilder(
                future: getAppVersion(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Версия приложения: ${snapshot.data}',
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showScreenChoiceModal(
    BuildContext context,
    SettingsScreenViewModel model,
  ) async {
    final theme = Theme.of(context);
    final currentIndex = model.activeNavbarRouteIndex;

    final selectedIndex = await showModalActionSheet<int>(
      context: context,
      useRootNavigator: true,
      title: 'Выберите экран',
      cancelLabel: 'Отмена',
      actions: List.generate(
        model.navbarRouteCount,
        (index) {
          final isSelected = index == currentIndex;

          return SheetAction<int>(
            label: model.activeNavbarRouteNames[index],
            key: index,
            isDefaultAction: isSelected,
            textStyle: TextStyle(
              color: isSelected ? theme.colorScheme.primary : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );

    if (selectedIndex != null) {
      model.activeNavbarRouteIndex = selectedIndex;
    }

    return selectedIndex;
  }
}
