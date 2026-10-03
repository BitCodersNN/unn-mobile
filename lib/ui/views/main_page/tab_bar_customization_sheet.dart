// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

Future<List<String>?> showTabBarCustomizationSheet(
  BuildContext context, {
  required List<MainPageRouteData> routes,
  required List<String> initialPaths,
  required String selectedPath,
}) =>
    showModalBottomSheet<List<String>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.94,
        child: TabBarCustomizationSheet(
          routes: routes,
          initialPaths: initialPaths,
          selectedPath: selectedPath,
        ),
      ),
    );

class TabBarCustomizationSheet extends StatefulWidget {
  final List<MainPageRouteData> routes;
  final List<String> initialPaths;
  final String selectedPath;

  const TabBarCustomizationSheet({
    required this.routes,
    required this.initialPaths,
    required this.selectedPath,
    super.key,
  });

  @override
  State<TabBarCustomizationSheet> createState() =>
      _TabBarCustomizationSheetState();
}

class _TabBarCustomizationSheetState extends State<TabBarCustomizationSheet> {
  late List<String?> _slots;
  late int _selectedSlot;
  bool _saving = false;

  void _resetSlots(Iterable<String> paths) {
    final normalized = TabBarPreferences.normalize(
      paths,
      allowed: widget.routes.map((route) => route.pagePath),
    );
    _slots = List<String?>.filled(4, null);
    final editable = normalized.where((path) => path != 'more').toList();
    for (var index = 0; index < editable.length; index++) {
      _slots[index] = editable[index];
    }
  }

  @override
  void initState() {
    super.initState();
    _resetSlots(widget.initialPaths);
    final index = _slots.indexOf(widget.selectedPath);
    _selectedSlot = index < 0 ? 0 : index;
  }

  void _choose(String path) {
    if (path == 'more') {
      return;
    }
    setState(() {
      final existing = _slots.indexOf(path);
      if (existing >= 0 && existing != _selectedSlot) {
        if (_slots[_selectedSlot] == null && existing < 2) {
          _selectedSlot = existing;
          return;
        }
        _slots[existing] = _slots[_selectedSlot];
      }
      _slots[_selectedSlot] = path;
    });
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      final paths = [..._slots.whereType<String>(), 'more'];
      await AppSettings.updateTabBarPaths(paths);
      if (mounted) {
        Navigator.of(context).pop(paths);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить нижнее меню')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adding = _slots[_selectedSlot] == null;
    final canRemove = _selectedSlot >= 2;
    return MediaQuery.withNoTextScaling(
      child: PopScope(
        canPop: !_saving,
        child: AbsorbPointer(
          absorbing: _saving,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Быстрый доступ',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => setState(() {
                              _resetSlots(TabBarPreferences.defaultPaths);
                              _selectedSlot = 0;
                            }),
                            child: const Text('Сброс'),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            tooltip: 'Закрыть',
                            color: theme.colorScheme.onSurfaceVariant,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
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
                                (constraints.maxWidth - 8 * (columns - 1)) /
                                    columns;
                            return Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              children: [
                                for (final route in widget.routes.where(
                                  (route) => route.pagePath != 'more',
                                ))
                                  SizedBox(
                                    width: width,
                                    child: _option(
                                      context,
                                      icon: route.unselectedIcon,
                                      label: route.pageTitle,
                                      selected: !adding &&
                                          _slots[_selectedSlot] ==
                                              route.pagePath,
                                      onTap: route.isDisabled
                                          ? null
                                          : () => _choose(route.pagePath),
                                    ),
                                  ),
                                SizedBox(
                                  width: width,
                                  child: _option(
                                    context,
                                    icon: Icons.block,
                                    label: 'Не показывать',
                                    selected: adding,
                                    onTap: canRemove
                                        ? () => setState(() {
                                              _slots[_selectedSlot] = null;
                                            })
                                        : null,
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
                      child: Row(
                        children: [
                          for (var index = 0; index < 4; index++)
                            Expanded(child: _previewSlot(context, index)),
                          Expanded(
                            child: Semantics(
                              enabled: false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 2,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.menu,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.35),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 14,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Ещё',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withValues(
                                              alpha: 0.35,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_saving ? 'Сохранение…' : 'Готово'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewSlot(BuildContext context, int index) {
    final path = _slots[index];
    final route = path == null
        ? null
        : widget.routes.firstWhere((route) => route.pagePath == path);
    final theme = Theme.of(context);
    final selected = _selectedSlot == index;
    final content = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: ValueKey('quick-access-slot-$index'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedSlot = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                (selected ? route?.selectedIcon : route?.unselectedIcon) ??
                    (selected ? Icons.block : Icons.add),
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 14,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    route?.pageTitle ??
                        (selected ? 'Не показывать' : 'Добавить'),
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .tabLabelTextStyle
                        .copyWith(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) =>
          details.data != index && !(details.data < 2 && _slots[index] == null),
      onAcceptWithDetails: (details) => setState(() {
        final moved = _slots[details.data];
        _slots[details.data] = _slots[index];
        _slots[index] = moved;
        _selectedSlot = index;
      }),
      builder: (context, candidates, rejected) => path == null
          ? content
          : LongPressDraggable<int>(
              data: index,
              feedback: Material(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Icon(route!.unselectedIcon),
                ),
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: content),
              child: content,
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
