import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/viewmodels/library.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/adaptive_dialog_action.dart';

class SettingsScreenView extends StatelessWidget {
  const SettingsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: BaseView<SettingsScreenViewModel>(
        builder: (context, model, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ...ListTile.divideTiles(
                  context: context,
                  tiles: [
                    SwitchListTile.adaptive(
                      title: const Text('Вибрация'),
                      value: model.vibrationEnabled,
                      onChanged: (bool value) {
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
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog.adaptive(
                            title: const Text('Выйти из аккаунта?'),
                            actions: [
                              AdaptiveDialogAction(
                                onPressed: () async {
                                  await model.logout();
                                  if (context.mounted) {
                                    GoRouter.of(context).go(loadingPageRoute);
                                  }
                                },
                                child: Text(
                                  'Выйти',
                                  style:
                                      TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                              AdaptiveDialogAction(
                                onPressed: () {
                                  GoRouter.of(context).pop();
                                },
                                child: const Text('Отмена'),
                              ),
                            ],
                          ),
                        );
                      },
                      textColor: theme.colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> _showScreenChoiceModal(
    BuildContext context,
    SettingsScreenViewModel model,
  ) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final theme = Theme.of(context);
        return BaseView<SettingsScreenViewModel>(
          model: model,
          builder: (context, model, _) {
            return Container(
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
                      color: Color(0xE5A2A2A2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 400.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          model.navbarRouteCount,
                          (index) {
                            return RadioListTile.adaptive(
                              title: Text(
                                model.activeNavbarRouteNames[index],
                              ),
                              value: index,
                              groupValue: model.activeNavbarRouteIndex,
                              onChanged: (value) {
                                model.activeNavbarRouteIndex = value ?? 0;
                                GoRouter.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
