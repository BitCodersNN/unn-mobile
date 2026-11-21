// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_version.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_mode.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_settings.dart';
import 'package:unn_mobile/core/viewmodels/main_page/settings/settings_screen_view_model.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/settings_minutes_slider.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/settings_section.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/settings_tile.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar/tab_bar_customization_sheet.dart';

class SettingsScreenView extends StatefulWidget {
  final bool hasAccount;

  const SettingsScreenView({super.key, this.hasAccount = true});

  @override
  State<SettingsScreenView> createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<SettingsScreenView>
    with WidgetsBindingObserver {
  SettingsScreenViewModel? _model;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_model?.refreshActivityStatus());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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

  Future<void> _selectActivityMode(SettingsScreenViewModel model) async {
    final mode = await _selectSetting(
      title: 'Занятие на экране блокировки',
      current: model.activitySettings.mode,
      options: {
        for (final mode in ScheduleActivityMode.values) mode: mode.label,
      },
    );
    if (mounted && mode != null && mode != model.activitySettings.mode) {
      await model.updateActivitySettings(
        model.activitySettings.copyWith(mode: mode),
      );
    }
  }

  Widget _scheduleActivitySection(SettingsScreenViewModel model) {
    final status = model.activityStatus;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final enabled =
        model.activitySettings.mode != ScheduleActivityMode.disabled;
    return SettingsSection(
      title: 'Расписание',
      children: [
        SettingsActionTile(
          icon: Icons.calendar_today_outlined,
          title: 'Источник своего расписания',
          subtitle: model.useRaspSchedule
              ? 'Загружается с rasp.unn.ru'
              : 'Загружается с Портала',
          onTap: () => _selectScheduleSource(model),
        ),
        SettingsMinutesSlider(
          icon: Icons.timer_outlined,
          title: 'Показывать до начала',
          subtitle: 'Также для бейджа в расписании. 0 — только с начала пары.',
          value: model.activitySettings.beforeMinutes,
          min: ScheduleActivitySettings.minimumMinutes,
          max: ScheduleActivitySettings.maximumMinutes,
          onChangeEnd: (minutes) => unawaited(
            model.updateActivitySettings(
              model.activitySettings.copyWith(beforeMinutes: minutes),
            ),
          ),
        ),
        if (widget.hasAccount) ...[
          SettingsActionTile(
            icon: Icons.lock_clock_outlined,
            title: isIOS ? 'Live Activities' : 'Live Updates',
            subtitle: status?.supported == false
                ? (isIOS ? 'Доступно с iOS 16.2' : 'Доступно с Android 16')
                : model.activitySettings.mode.label,
            onTap: status?.supported == false
                ? null
                : () => _selectActivityMode(model),
          ),
          if (model.activitySettings.mode == ScheduleActivityMode.brief)
            SettingsMinutesSlider(
              icon: Icons.hourglass_bottom_rounded,
              title: 'Показывать после начала',
              subtitle: '0 — скрывать с началом пары.',
              value: model.activitySettings.initialMinutes,
              min: ScheduleActivitySettings.minimumMinutes,
              max: ScheduleActivitySettings.maximumMinutes,
              onChangeEnd: (minutes) => unawaited(
                model.updateActivitySettings(
                  model.activitySettings.copyWith(initialMinutes: minutes),
                ),
              ),
            ),
          if (enabled && status?.authorized == false)
            SettingsActionTile(
              icon: Icons.notifications_off_outlined,
              title: 'Разрешить отображение в системе',
              subtitle: isIOS
                  ? 'Включите Live Activities в настройках приложения'
                  : 'Разрешите уведомления и Live Updates',
              onTap: () => model.openActivitySettings(),
            ),
          if (enabled && !isIOS && status?.exactAlarms == false)
            SettingsActionTile(
              icon: Icons.alarm_outlined,
              title: 'Точное время обновления',
              subtitle: 'Без разрешения системы начало и завершение могут задерживаться',
              onTap: () => model.openActivitySettings(exactAlarms: true),
            ),
          if (enabled && isIOS)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Без сервера переходы и скрытие Live Activity в фоне могут задерживаться. '
                'Планирование запуска доступно с iOS 26; на более ранних версиях нужно открыть приложение незадолго до пары. '
                'Число запланированных активностей ограничивает iOS. Используется сохранённое личное расписание.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _openSystemAppSettings(SettingsScreenViewModel model) async {
    final opened = await model.openSystemAppSettings();
    if (mounted && !opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть системные настройки')),
      );
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
          onModelReady: (model) {
            _model = model;
            unawaited(model.refreshActivityStatus());
          },
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
                        icon: Icons.app_settings_alt_outlined,
                        title: 'Системные настройки приложения',
                        subtitle: 'Разрешения, уведомления и другие параметры',
                        onTap: () => _openSystemAppSettings(model),
                      ),
                      if (widget.hasAccount) ...[
                        SettingsActionTile(
                          icon: Icons.tune_rounded,
                          title: 'Быстрый доступ',
                          subtitle: 'Состав и порядок вкладок нижнего меню',
                          onTap: _customizeTabBar,
                        ),
                      ],
                    ],
                  ),
                  if (widget.hasAccount)
                    SettingsSection(
                      title: 'Лента',
                      children: [
                        SettingsActionTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Порядок комментариев',
                          subtitle: model.reverseComments
                              ? 'Сначала новые'
                              : 'Сначала старые',
                          onTap: () => _selectCommentOrder(model),
                        ),
                      ],
                    ),
                  _scheduleActivitySection(model),
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
