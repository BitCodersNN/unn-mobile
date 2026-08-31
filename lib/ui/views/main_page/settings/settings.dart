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
                      ListTile(
                        title: const Text('Начальный экран'),
                        trailing: Text(model.initialScreenName),
                        onTap: () async {
                          await _showScreenChoiceModal(context, model);
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
  ) =>
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        builder: (context) {
          final theme = Theme.of(context);
          return BaseView<SettingsScreenViewModel>(
            model: model,
            builder: (context, model, _) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Выберите экран',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Divider(
                      indent: 8,
                      endIndent: 8,
                      thickness: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 400.0,
                    ),
                    child: SingleChildScrollView(
                      child: RadioGroup<int>(
                        groupValue: model.activeNavbarRouteIndex,
                        onChanged: (value) {
                          model.activeNavbarRouteIndex = value ?? 0;
                          GoRouter.of(context).pop();
                        },
                        child: Column(
                          children: List.generate(
                            model.navbarRouteCount,
                            (index) => RadioListTile.adaptive(
                              title: Text(
                                model.activeNavbarRouteNames[index],
                              ),
                              value: index,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
}
