// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_version.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/app_theme_mode.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_mode.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_settings.dart';
import 'package:unn_mobile/core/viewmodels/main_page/settings/settings_screen_view_model.dart';
import 'package:unn_mobile/ui/actions/custom_palette_share_action.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/theme/app_theme.dart';
import 'package:unn_mobile/ui/theme/theme_palette.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/settings/custom_palette_editor_screen.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/settings_minutes_slider.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/settings_section.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/settings_tile.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/theme_palette_selector.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar/tab_bar_customization_sheet.dart';
import 'package:unn_mobile/ui/views/main_page/widgets/main_page_app_bar.dart';
import 'package:unn_mobile/ui/widgets/dialogs/custom_palette_import_dialog.dart';

const _themeLabels = {
  AppThemeMode.system: 'Системная',
  AppThemeMode.light: 'Светлая',
  AppThemeMode.dark: 'Тёмная',
};

class SettingsScreenView extends StatefulWidget {
  final bool hasAccount;

  const SettingsScreenView({super.key, this.hasAccount = true});

  @override
  State<SettingsScreenView> createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<SettingsScreenView>
    with WidgetsBindingObserver {
  SettingsScreenViewModel? _model;
  late final Future<String> _version = getAppVersion();

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

  Future<void> _selectTheme(SettingsScreenViewModel model) async {
    final mode = await _selectSetting(
      title: 'Тема',
      current: model.themeMode,
      options: _themeLabels,
    );
    if (!mounted || mode == null || mode == model.themeMode) {
      return;
    }
    await _saveThemeChange(() => model.setThemeMode(mode));
  }

  Future<bool> _saveThemeChange(Future<void> Function() update) async {
    try {
      await update();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить тему')),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _importCustomPalette(
    SettingsScreenViewModel model, {
    required Brightness brightness,
  }) async {
    final imported = await showCustomPaletteImportDialog(
      context,
      brightness: brightness,
    );
    if (!mounted || imported == null) {
      return;
    }
    final saved = await _saveThemeChange(
      () => model.saveCustomPalette(imported, brightness: brightness),
    );
    if (mounted && saved) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Палитра загружена')));
    }
  }

  Future<void> _shareCustomPalette(
    SettingsScreenViewModel model, {
    required Brightness brightness,
  }) async {
    final config = model.customPalette(brightness);
    if (config == null) {
      return;
    }
    await shareCustomPalette(context, config, brightness: brightness);
  }

  Future<void> _openCustomPaletteEditor(
    SettingsScreenViewModel model, {
    required Brightness brightness,
  }) async {
    final isDark = brightness == Brightness.dark;
    final initialConfig =
        model.customPalette(brightness) ??
        (isDark
            ? CustomPaletteConfig.defaultDark()
            : CustomPaletteConfig.defaultLight());
    final presets = isDark ? AppTheme.darkPalettes : AppTheme.lightPalettes;
    final result = await Navigator.of(context, rootNavigator: true)
        .push<CustomPaletteConfig>(
          MaterialPageRoute<CustomPaletteConfig>(
            builder: (_) => CustomPaletteEditorScreen(
              brightness: brightness,
              initialConfig: initialConfig,
              builtInPresets: presets,
            ),
          ),
        );
    if (!mounted || result == null) {
      return;
    }
    await _saveThemeChange(
      () => model.saveCustomPalette(result, brightness: brightness),
    );
  }

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

  Future<void> _openSystemAppSettings(SettingsScreenViewModel model) async {
    final opened = await model.openSystemAppSettings();
    if (mounted && !opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть системные настройки')),
      );
    }
  }

  Future<void> _updateShowTabBarDate(
    SettingsScreenViewModel model,
    bool value,
  ) async {
    final saved = await model.updateShowTabBarDate(value: value);
    if (!saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить настройку даты')),
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
      appBar: buildMainPageAppBar(
        context,
        title: 'Настройки',
        backgroundColor: colors.surfaceContainerLow,
      ),
      body: SafeArea(
        top: false,
        child: BaseView<SettingsScreenViewModel>(
          onModelReady: (model) {
            _model = model;
            unawaited(model.refreshActivityStatus());
          },
          onDispose: (model) => model.dispose(),
          builder: (context, model, _) => Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _AppearanceSection(
                    model: model,
                    onSelectTheme: () => _selectTheme(model),
                    onSaveThemeChange: _saveThemeChange,
                    onEditCustomPalette: (brightness) =>
                        _openCustomPaletteEditor(model, brightness: brightness),
                    onImportCustomPalette: (brightness) =>
                        _importCustomPalette(model, brightness: brightness),
                    onShareCustomPalette: (brightness) =>
                        _shareCustomPalette(model, brightness: brightness),
                  ),
                  _ApplicationSection(
                    model: model,
                    hasAccount: widget.hasAccount,
                    onUpdateShowTabBarDate: (value) =>
                        unawaited(_updateShowTabBarDate(model, value)),
                    onOpenSystemAppSettings: () =>
                        _openSystemAppSettings(model),
                    onCustomizeTabBar: _customizeTabBar,
                  ),
                  if (widget.hasAccount)
                    _FeedSection(
                      reverseComments: model.reverseComments,
                      onSelectCommentOrder: () => _selectCommentOrder(model),
                    ),
                  _ScheduleSection(
                    model: model,
                    hasAccount: widget.hasAccount,
                    onSelectScheduleSource: () => _selectScheduleSource(model),
                    onSelectActivityMode: () => _selectActivityMode(model),
                  ),
                  _AppDataSection(
                    model: model,
                    onClearCache: () => _clearCache(model),
                  ),
                  if (widget.hasAccount)
                    _AccountSection(onLogout: () => _logout(model)),
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

class _AppearanceSection extends StatelessWidget {
  final SettingsScreenViewModel model;
  final VoidCallback onSelectTheme;
  final Future<bool> Function(Future<void> Function() update) onSaveThemeChange;
  final void Function(Brightness brightness) onEditCustomPalette;
  final void Function(Brightness brightness) onImportCustomPalette;
  final void Function(Brightness brightness) onShareCustomPalette;

  const _AppearanceSection({
    required this.model,
    required this.onSelectTheme,
    required this.onSaveThemeChange,
    required this.onEditCustomPalette,
    required this.onImportCustomPalette,
    required this.onShareCustomPalette,
  });

  Widget _paletteSelector<T extends Enum>({
    required Brightness brightness,
    required String title,
    required List<ThemePalette<T>> palettes,
    required T selected,
    required T customValue,
    required bool isCustomConfigured,
    required Future<void> Function(T palette) onSelectPalette,
  }) => ThemePaletteSelector<T>(
    title: title,
    palettes: palettes,
    selected: selected,
    customValue: customValue,
    isCustomConfigured: isCustomConfigured,
    onEditCustom: () => onEditCustomPalette(brightness),
    onImportCustom: () => onImportCustomPalette(brightness),
    onShareCustom: () => onShareCustomPalette(brightness),
    onSelected: (index) =>
        onSaveThemeChange(() => onSelectPalette(palettes[index].value)),
  );

  @override
  Widget build(BuildContext context) => SettingsSection(
    title: 'Оформление',
    dividerIndent: 16,
    children: [
      SettingsActionTile(
        icon: Icons.brightness_6_outlined,
        title: 'Тема',
        subtitle: _themeLabels[model.themeMode],
        onTap: onSelectTheme,
      ),
      if (model.themeMode != AppThemeMode.dark)
        _paletteSelector<AppLightTheme>(
          brightness: Brightness.light,
          title: 'Светлая палитра',
          palettes: AppTheme.lightPalettesFor(model.customLightPalette),
          selected: model.lightTheme,
          customValue: AppLightTheme.custom,
          isCustomConfigured: model.hasCustomLightPalette,
          onSelectPalette: model.setLightTheme,
        ),
      if (model.themeMode != AppThemeMode.light)
        _paletteSelector<AppDarkTheme>(
          brightness: Brightness.dark,
          title: 'Тёмная палитра',
          palettes: AppTheme.darkPalettesFor(model.customDarkPalette),
          selected: model.darkTheme,
          customValue: AppDarkTheme.custom,
          isCustomConfigured: model.hasCustomDarkPalette,
          onSelectPalette: model.setDarkTheme,
        ),
    ],
  );
}

class _ApplicationSection extends StatelessWidget {
  final SettingsScreenViewModel model;
  final bool hasAccount;
  final ValueChanged<bool> onUpdateShowTabBarDate;
  final VoidCallback onOpenSystemAppSettings;
  final VoidCallback onCustomizeTabBar;

  const _ApplicationSection({
    required this.model,
    required this.hasAccount,
    required this.onUpdateShowTabBarDate,
    required this.onOpenSystemAppSettings,
    required this.onCustomizeTabBar,
  });

  @override
  Widget build(BuildContext context) => SettingsSection(
    title: 'Приложение',
    children: [
      SettingsSwitchTile(
        icon: Icons.vibration_rounded,
        title: 'Вибрация',
        subtitle: 'Тактильный отклик при действиях',
        value: model.vibrationEnabled,
        onChanged: (value) => model.vibrationEnabled = value,
      ),
      if (hasAccount)
        SettingsSwitchTile(
          icon: Icons.today_outlined,
          title: 'Дата в заголовке',
          subtitle: 'Показывать дату на вкладках нижнего меню',
          value: model.showTabBarDate,
          onChanged: onUpdateShowTabBarDate,
        ),
      SettingsActionTile(
        icon: Icons.app_settings_alt_outlined,
        title: 'Системные настройки приложения',
        subtitle: 'Разрешения, уведомления и другие параметры',
        onTap: onOpenSystemAppSettings,
      ),
      if (hasAccount)
        SettingsActionTile(
          icon: Icons.tune_rounded,
          title: 'Быстрый доступ',
          subtitle: 'Состав и порядок вкладок нижнего меню',
          onTap: onCustomizeTabBar,
        ),
    ],
  );
}

class _FeedSection extends StatelessWidget {
  final bool reverseComments;
  final VoidCallback onSelectCommentOrder;

  const _FeedSection({
    required this.reverseComments,
    required this.onSelectCommentOrder,
  });

  @override
  Widget build(BuildContext context) => SettingsSection(
    title: 'Лента',
    children: [
      SettingsActionTile(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Порядок комментариев',
        subtitle: reverseComments ? 'Сначала новые' : 'Сначала старые',
        onTap: onSelectCommentOrder,
      ),
    ],
  );
}

class _ScheduleSection extends StatelessWidget {
  final SettingsScreenViewModel model;
  final bool hasAccount;
  final VoidCallback onSelectScheduleSource;
  final VoidCallback onSelectActivityMode;

  const _ScheduleSection({
    required this.model,
    required this.hasAccount,
    required this.onSelectScheduleSource,
    required this.onSelectActivityMode,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onSelectScheduleSource,
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
        if (hasAccount) ...[
          SettingsActionTile(
            icon: Icons.lock_clock_outlined,
            title: isIOS ? 'Live Activities' : 'Live Updates',
            subtitle: status?.supported == false
                ? (isIOS ? 'Доступно с iOS 16.2' : 'Доступно с Android 16')
                : model.activitySettings.mode.label,
            onTap: status?.supported == false ? null : onSelectActivityMode,
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
              onTap: model.openActivitySettings,
            ),
          if (enabled && !isIOS && status?.exactAlarms == false)
            SettingsActionTile(
              icon: Icons.alarm_outlined,
              title: 'Точное время обновления',
              subtitle: 'Без разрешения системы начало и завершение могут задерживаться',
              onTap: () => model.openActivitySettings(exactAlarms: true),
            ),
          if (enabled && isIOS) const _IosActivityNotice(),
        ],
      ],
    );
  }
}

class _IosActivityNotice extends StatelessWidget
    implements SettingsDividerIndent {
  const _IosActivityNotice();

  @override
  double get dividerIndent => 16;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      'Без сервера переходы и скрытие Live Activity в фоне могут задерживаться. '
      'Планирование запуска доступно с iOS 26; на более ранних версиях нужно открыть приложение незадолго до пары. '
      'Число запланированных активностей ограничивает iOS. Используется сохранённое личное расписание.',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}

class _AppDataSection extends StatelessWidget {
  final SettingsScreenViewModel model;
  final VoidCallback onClearCache;

  const _AppDataSection({required this.model, required this.onClearCache});

  @override
  Widget build(BuildContext context) => SettingsSection(
    title: 'Данные приложения',
    children: [
      SettingsSwitchTile(
        icon: Icons.insights_outlined,
        title: 'Сбор телеметрии',
        subtitle: 'Помогает находить ошибки и улучшать приложение',
        value: model.analyticsEnabled,
        onChanged: (value) => model.analyticsEnabled = value,
      ),
      SettingsActionTile(
        icon: Icons.cleaning_services_outlined,
        title: 'Очистить кэш',
        subtitle: 'Удалить временно загруженные файлы',
        showChevron: false,
        onTap: onClearCache,
      ),
    ],
  );
}

class _AccountSection extends StatelessWidget {
  final VoidCallback onLogout;

  const _AccountSection({required this.onLogout});

  @override
  Widget build(BuildContext context) => SettingsSection(
    title: 'Аккаунт',
    children: [
      SettingsActionTile(
        icon: Icons.logout_rounded,
        title: 'Выйти из аккаунта',
        color: Theme.of(context).colorScheme.error,
        showChevron: false,
        onTap: onLogout,
      ),
    ],
  );
}
