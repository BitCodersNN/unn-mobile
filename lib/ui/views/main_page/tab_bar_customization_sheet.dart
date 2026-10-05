// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';
import 'package:unn_mobile/core/viewmodels/main_page/tab_bar_customization_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_item_content.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_reorder_preview.dart';
import 'package:unn_mobile/ui/widgets/app_modal_sheet.dart';

Future<List<String>?> showTabBarCustomizationSheet(
  BuildContext context, {
  required List<MainPageRouteData> routes,
  List<String>? initialPaths,
  String? selectedPath,
  TabBarPathsSaver savePaths = AppSettings.updateTabBarPaths,
}) {
  final paths = TabBarPreferences.normalize(
    initialPaths ?? AppSettings.tabBarPaths.value,
    allowed: routes.map((route) => route.pagePath),
  );
  return showAppModalSheet<List<String>>(
    context: context,
    builder: (_) => TabBarCustomizationSheet(
      routes: routes,
      initialPaths: paths,
      selectedPath: selectedPath ?? paths.first,
      savePaths: savePaths,
    ),
  );
}

class TabBarCustomizationSheet extends StatefulWidget {
  final List<MainPageRouteData> routes;
  final List<String> initialPaths;
  final String selectedPath;
  final TabBarPathsSaver savePaths;

  const TabBarCustomizationSheet({
    required this.routes,
    required this.initialPaths,
    required this.selectedPath,
    this.savePaths = AppSettings.updateTabBarPaths,
    super.key,
  });

  @override
  State<TabBarCustomizationSheet> createState() =>
      _TabBarCustomizationSheetState();
}

class _TabBarCustomizationSheetState extends State<TabBarCustomizationSheet> {
  late final TabBarCustomizationViewModel _model;
  late final Map<String, MainPageRouteData> _routesByPath;

  @override
  void initState() {
    super.initState();
    _routesByPath = {for (final route in widget.routes) route.pagePath: route};
    _model = TabBarCustomizationViewModel(
      allowedPaths: _routesByPath.keys,
      initialPaths: widget.initialPaths,
      selectedPath: widget.selectedPath,
      savePaths: widget.savePaths,
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final paths = await _model.save();
      if (mounted && paths != null) {
        Navigator.of(context).pop(paths);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить нижнее меню')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _model,
        builder: (context, _) => _buildSheet(context),
      );

  Widget _buildSheet(BuildContext context) {
    final theme = Theme.of(context);
    final adding = _model.selectedPath == null;
    final canRemove = _model.canRemove;
    return MediaQuery.withNoTextScaling(
      child: PopScope(
        canPop: !_model.isSaving,
        child: AbsorbPointer(
          absorbing: _model.isSaving,
          child: AppModalSheet(
            title: 'Быстрый доступ',
            leading: TextButton(
              onPressed: _model.reset,
              child: const Text('Сброс'),
            ),
            footer: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      child: TabBarReorderPreview(
                        itemCount: TabBarPreferences.maxTabs,
                        itemKey: (index) =>
                            index == TabBarPreferences.editableSlotCount
                                ? TabBarPreferences.morePath
                                : _model.slots[index] ?? 'empty-$index',
                        canDrag: (index) =>
                            !_model.isSaving &&
                            index < TabBarPreferences.editableSlotCount &&
                            _model.slots[index] != null,
                        canMove: _model.canMove,
                        onSelected: _model.selectSlot,
                        onMove: _model.move,
                        itemBuilder: (context, index) =>
                            index < TabBarPreferences.editableSlotCount
                                ? _previewSlot(context, index)
                                : _morePreview(context),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _model.isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_model.isSaving ? 'Сохранение…' : 'Готово'),
                    ),
                  ),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  Text(
                    'Вы можете менять некоторые вкладки в нижнем меню. Нажмите на иконку внизу, а затем выберите нужный раздел.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const columns = 4;
                      final width =
                          (constraints.maxWidth - 8 * (columns - 1)) / columns;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        children: [
                          for (final route in widget.routes.where(
                            (route) =>
                                route.pagePath != TabBarPreferences.morePath,
                          ))
                            SizedBox(
                              width: width,
                              child: _option(
                                context,
                                icon: route.unselectedIcon,
                                label: route.pageTitle,
                                selected: !adding &&
                                    _model.selectedPath == route.pagePath,
                                onTap: route.isDisabled
                                    ? null
                                    : () => _model.choose(route.pagePath),
                              ),
                            ),
                          SizedBox(
                            width: width,
                            child: _option(
                              context,
                              icon: Icons.block,
                              label: 'Не показывать',
                              selected: adding,
                              onTap: canRemove ? _model.removeSelected : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewSlot(BuildContext context, int index) {
    final path = _model.slots[index];
    final route = path == null ? null : _routesByPath[path];
    final theme = Theme.of(context);
    final selected = _model.selectedSlot == index;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        key: ValueKey('quick-access-slot-$index'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _model.selectSlot(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          child: TabBarItemContent(
            icon: (selected ? route?.selectedIcon : route?.unselectedIcon) ??
                (selected ? Icons.block : Icons.add),
            label:
                route?.pageTitle ?? (selected ? 'Не показывать' : 'Добавить'),
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            labelStyle:
                CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
          ),
        ),
      ),
    );
  }

  Widget _morePreview(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);
    return Semantics(
      enabled: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: TabBarItemContent(
          icon: Icons.menu,
          label: 'Ещё',
          color: color,
          labelStyle: TextStyle(color: color),
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Opacity(
          opacity: onTap == null ? 0.4 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Icon(
                    icon,
                    size: 26,
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
