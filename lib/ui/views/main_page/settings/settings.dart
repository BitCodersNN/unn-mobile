// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_version.dart';
import 'package:unn_mobile/core/viewmodels/main_page/settings/settings_screen_view_model.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/settings_section.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/settings_tile.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar/tab_bar_customization_sheet.dart';

class SettingsScreenView extends StatefulWidget {
  final bool hasAccount;

  const SettingsScreenView({super.key, this.hasAccount = true});

  @override
  State<SettingsScreenView> createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<SettingsScreenView> {
  late final Future<String> _version = getAppVersion();

  Future<void> _customizeTabBar() async {
    final routes = AppRouter.of(context).configuration.destinations;
    await showTabBarCustomizationSheet(context, routes: routes);
  }

  Future<T?> _selectSetting<T>({
    required String title,
    required T current,
    required Map<T, String> options,
  }) => showModalActionSheet<T>(
    context: context,
    title: title,
    cancelLabel: 'Отмена',
    actions: [
      for (final entry in options.entries)
        SheetAction(
          key: entry.key,
          label: entry.value,
          isDefaultAction: entry.key == current,
          icon: entry.key == current ? Icons.check_rounded : null,
        ),
    ],
  );

  Future<void> _selectCommentOrder(SettingsScreenViewModel model) async {
    final reverse = await _selectSetting(
      title: 'Порядок комментариев',
      current: model.reverseComments,
      options: const {true: 'Сначала новые', false: 'Сначала старые'},
    );
    if (mounted && reverse != null && reverse != model.reverseComments) {
      model.reverseComments = reverse;
    }
  }

  Future<void> _selectScheduleSource(SettingsScreenViewModel model) async {
    final useRasp = await _selectSetting(
      title: 'Источник своего расписания',
      current: model.useRaspSchedule,
      options: const {false: 'Портал', true: 'rasp.unn.ru'},
    );
    if (mounted && useRasp != null && useRasp != model.useRaspSchedule) {
      model.useRaspSchedule = useRasp;
    }
  }

  Future<void> _clearCache(SettingsScreenViewModel model) async {
    await model.clearCache();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Кэш очищен')));
    }
  }

  Future<void> _logout(SettingsScreenViewModel model) async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: 'Выйти из аккаунта?',
      okLabel: 'Выйти',
      cancelLabel: 'Отмена',
      isDestructiveAction: true,
    );
    if (result != OkCancelResult.ok || !mounted) {
      return;
    }
    await model.logout();
    if (mounted) {
      GoRouter.of(context).go(loadingPageRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: colors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: false,
        backgroundColor: colors.surfaceContainerLow,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: BaseView<SettingsScreenViewModel>(
          builder: (context, model, _) => Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  SettingsSection(
                    title: 'Приложение',
                    children: [
                      SettingsSwitchTile(
                        icon: Icons.vibration_rounded,
                        title: 'Вибрация',
                        subtitle: 'Тактильный отклик при действиях',
                        value: model.vibrationEnabled,
                        onChanged: (value) => model.vibrationEnabled = value,
                      ),
                      SettingsActionTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Источник своего расписания',
                        subtitle: model.useRaspSchedule
                            ? 'Загружается с rasp.unn.ru'
                            : 'Загружается с Портала',
                        onTap: () => _selectScheduleSource(model),
                      ),
                      if (widget.hasAccount) ...[
                        SettingsActionTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Порядок комментариев',
                          subtitle: model.reverseComments
                              ? 'Сначала новые'
                              : 'Сначала старые',
                          onTap: () => _selectCommentOrder(model),
                        ),
                        SettingsActionTile(
                          icon: Icons.tune_rounded,
                          title: 'Быстрый доступ',
                          subtitle: 'Состав и порядок вкладок нижнего меню',
                          onTap: _customizeTabBar,
                        ),
                      ],
                    ],
                  ),
                  SettingsSection(
                    title: 'Данные приложения',
                    children: [
                      SettingsSwitchTile(
                        icon: Icons.insights_outlined,
                        title: 'Сбор телеметрии',
                        subtitle:
                            'Помогает находить ошибки и улучшать приложение',
                        value: model.analyticsEnabled,
                        onChanged: (value) => model.analyticsEnabled = value,
                      ),
                      SettingsActionTile(
                        icon: Icons.cleaning_services_outlined,
                        title: 'Очистить кэш',
                        subtitle: 'Удалить временно загруженные файлы',
                        showChevron: false,
                        onTap: () => _clearCache(model),
                      ),
                    ],
                  ),
                  if (widget.hasAccount)
                    SettingsSection(
                      title: 'Аккаунт',
                      children: [
                        SettingsActionTile(
                          icon: Icons.logout_rounded,
                          title: 'Выйти из аккаунта',
                          color: colors.error,
                          showChevron: false,
                          onTap: () => _logout(model),
                        ),
                      ],
                    ),
                  FutureBuilder<String>(
                    future: _version,
                    builder: (context, snapshot) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        snapshot.hasData ? 'Версия ${snapshot.data}' : '',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
