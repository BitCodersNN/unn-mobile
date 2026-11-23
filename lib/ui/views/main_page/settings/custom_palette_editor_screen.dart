// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/viewmodels/main_page/settings/custom_palette_editor_view_model.dart';
import 'package:unn_mobile/ui/theme/app_theme.dart';
import 'package:unn_mobile/ui/theme/theme_palette.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/hsv_color_picker.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_live_preview.dart';
import 'package:unn_mobile/ui/widgets/segmented_tab_bar.dart';

sealed class _PresetMenuAction {
  const _PresetMenuAction();
}

final class _ApplyPresetAction extends _PresetMenuAction {
  final ThemeData theme;

  const _ApplyPresetAction(this.theme);
}

final class _ResetAllAction extends _PresetMenuAction {
  const _ResetAllAction();
}

class CustomPaletteEditorScreen extends StatelessWidget {
  final Brightness brightness;
  final CustomPaletteConfig initialConfig;
  final List<ThemePalette<Enum>> builtInPresets;
  final ValueChanged<CustomPaletteConfig>? onApply;

  const CustomPaletteEditorScreen({
    required this.brightness,
    required this.initialConfig,
    required this.builtInPresets,
    this.onApply,
    super.key,
  });

  @override
  Widget build(BuildContext context) => BaseView<CustomPaletteEditorViewModel>(
    createModel: () => CustomPaletteEditorViewModel(
      initialConfig: initialConfig,
      brightness: brightness,
      themeBuilder: (config, b) =>
          AppTheme.buildCustomTheme(config, brightness: b),
      slotColorResolver: AppTheme.colorForSlot,
    ),
    onDispose: (model) => model.dispose(),
    builder: (context, model, _) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;

      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text(
            brightness == Brightness.dark
                ? 'Своя тёмная палитра'
                : 'Своя светлая палитра',
          ),
          centerTitle: false,
          backgroundColor: colors.surface,
          scrolledUnderElevation: 0,
          actions: [
            PopupMenuButton<_PresetMenuAction>(
              tooltip: 'Пресеты и сброс',
              icon: Icon(
                Icons.palette_outlined,
                color: colors.onSurfaceVariant,
              ),
              onSelected: (action) {
                switch (action) {
                  case _ApplyPresetAction(:final theme):
                    model.applyPreset(AppTheme.configFromTheme(theme));
                  case _ResetAllAction():
                    model.resetAll();
                }
                onApply?.call(model.config);
              },
              itemBuilder: (context) => [
                for (final preset in builtInPresets)
                  PopupMenuItem<_PresetMenuAction>(
                    value: _ApplyPresetAction(preset.theme),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: preset.theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(preset.label),
                      ],
                    ),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem<_PresetMenuAction>(
                  value: _ResetAllAction(),
                  child: Row(
                    children: [
                      Icon(Icons.restart_alt_rounded, size: 18),
                      SizedBox(width: 10),
                      Text('Сбросить всё'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final topControls = Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedTabBar(
                        borderColor: theme.alternatingSurfaceColor,
                        selectedIndex: PaletteCategory.values.indexOf(
                          model.selectedCategory,
                        ),
                        onSelected: (index) =>
                            model.selectCategory(PaletteCategory.values[index]),
                        items: [
                          for (final category in PaletteCategory.values)
                            SegmentedTabItem(label: category.label),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: model.slotsForSelectedCategory.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final slot = model.slotsForSelectedCategory[index];
                            return _SlotPillChip(
                              label: slot.label,
                              color: model.colorForSlot(slot),
                              selected: slot == model.selectedSlot,
                              onTap: () => model.selectSlot(slot),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                  final preview = PaletteLivePreview(
                    previewTheme: model.previewTheme,
                    selectedCategory: model.selectedCategory,
                    selectedSlot: model.selectedSlot,
                    selectedSlotColor: model.currentColor,
                    onSlotSelected: model.selectSlotInCurrentCategory,
                  );
                  final colorStudio = Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: HsvColorPicker(
                      hsv: model.currentHsv,
                      hex: model.currentHex,
                      currentColor: model.currentColor,
                      canReset: model.isCurrentSlotCustomized,
                      onHueSaturationChanged: model.updateHueSaturation,
                      onValueChanged: model.updateValue,
                      onHexChanged: model.updateHex,
                      onReset: model.resetCurrentSlot,
                    ),
                  );

                  if (constraints.maxHeight >= 580) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                          child: topControls,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: preview,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: colorStudio,
                        ),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        topControls,
                        const SizedBox(height: 10),
                        SizedBox(height: 240, child: preview),
                        const SizedBox(height: 12),
                        colorStudio,
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pop(model.config),
                          child: const Text('Применить'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _SlotPillChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SlotPillChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected
            ? colors.primaryContainer.withValues(alpha: 0.55)
            : colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.6),
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? colors.onPrimaryContainer
                        : colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
