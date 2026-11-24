// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/viewmodels/main_page/settings/custom_palette_editor_view_model.dart';
import 'package:unn_mobile/ui/theme/app_theme.dart';
import 'package:unn_mobile/ui/theme/palette_slot_labels.dart';
import 'package:unn_mobile/ui/theme/theme_palette.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/hsv_color_picker.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_live_preview.dart';
import 'package:unn_mobile/ui/widgets/segmented_tab_bar.dart';

const double _editorMaxWidth = 640;

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

class CustomPaletteEditorScreen extends StatefulWidget {
  final Brightness brightness;
  final CustomPaletteConfig initialConfig;
  final List<ThemePalette<Enum>> builtInPresets;

  const CustomPaletteEditorScreen({
    required this.brightness,
    required this.initialConfig,
    required this.builtInPresets,
    super.key,
  });

  @override
  State<CustomPaletteEditorScreen> createState() =>
      _CustomPaletteEditorScreenState();
}

class _CustomPaletteEditorScreenState extends State<CustomPaletteEditorScreen> {
  CustomPaletteConfig? _cachedConfig;
  Brightness? _cachedBrightness;
  ThemeData? _cachedPreviewTheme;

  ThemeData _previewThemeFor(
    CustomPaletteConfig config,
    Brightness brightness,
  ) {
    if (_cachedPreviewTheme != null &&
        _cachedConfig == config &&
        _cachedBrightness == brightness) {
      return _cachedPreviewTheme!;
    }
    _cachedConfig = config;
    _cachedBrightness = brightness;
    return _cachedPreviewTheme = AppTheme.buildCustomTheme(
      config,
      brightness: brightness,
    );
  }

  Color _resolveSlotColor(
    CustomPaletteConfig config,
    Brightness brightness,
    PaletteColorSlot slot,
  ) => AppTheme.colorForSlot(_previewThemeFor(config, brightness), slot);

  @override
  Widget build(BuildContext context) => BaseView<CustomPaletteEditorViewModel>(
    createModel: () => CustomPaletteEditorViewModel(
      initialConfig: widget.initialConfig,
      brightness: widget.brightness,
      slotColorResolver: _resolveSlotColor,
    ),
    onDispose: (model) => model.dispose(),
    builder: (context, model, _) {
      final colors = Theme.of(context).colorScheme;
      final previewTheme = _previewThemeFor(model.config, widget.brightness);

      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text(
            widget.brightness == Brightness.dark
                ? 'Своя тёмная палитра'
                : 'Своя светлая палитра',
          ),
          centerTitle: false,
          backgroundColor: colors.surface,
          scrolledUnderElevation: 0,
          actions: [
            _PresetMenuButton(
              builtInPresets: widget.builtInPresets,
              onPresetSelected: model.applyPreset,
              onResetAll: model.resetAll,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _editorMaxWidth),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final topControls = _CategorySlotSelector(
                    selectedCategory: model.selectedCategory,
                    selectedSlot: model.selectedSlot,
                    slots: model.slotsForSelectedCategory,
                    colorForSlot: model.colorForSlot,
                    onCategorySelected: model.selectCategory,
                    onSlotSelected: model.selectSlot,
                  );
                  final preview = PaletteLivePreview(
                    previewTheme: previewTheme,
                    selectedCategory: model.selectedCategory,
                    selectedSlot: model.selectedSlot,
                    selectedSlotColor: model.currentColor,
                    onSlotSelected: model.selectSlotInCurrentCategory,
                  );
                  final colorStudio = _ColorStudioCard(
                    selectedSlot: model.selectedSlot,
                    hsv: model.currentHsv,
                    hex: model.currentHex,
                    currentColor: model.currentColor,
                    canReset: model.isCurrentSlotCustomized,
                    onHueSaturationChanged: model.updateHueSaturation,
                    onValueChanged: model.updateValue,
                    onHexChanged: model.updateHex,
                    onReset: model.resetCurrentSlot,
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
        bottomNavigationBar: _EditorBottomBar(
          onCancel: () => Navigator.of(context).pop(),
          onApply: () => Navigator.of(context).pop(model.config),
        ),
      );
    },
  );
}

class _PresetMenuButton extends StatelessWidget {
  final List<ThemePalette<Enum>> builtInPresets;
  final ValueChanged<CustomPaletteConfig> onPresetSelected;
  final VoidCallback onResetAll;

  const _PresetMenuButton({
    required this.builtInPresets,
    required this.onPresetSelected,
    required this.onResetAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<_PresetMenuAction>(
      tooltip: 'Пресеты и сброс',
      icon: Icon(Icons.palette_outlined, color: colors.onSurfaceVariant),
      onSelected: (action) {
        switch (action) {
          case _ApplyPresetAction(:final theme):
            onPresetSelected(AppTheme.configFromTheme(theme));
          case _ResetAllAction():
            onResetAll();
        }
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
    );
  }
}

class _CategorySlotSelector extends StatelessWidget {
  final PaletteCategory selectedCategory;
  final PaletteColorSlot selectedSlot;
  final List<PaletteColorSlot> slots;
  final Color Function(PaletteColorSlot slot) colorForSlot;
  final ValueChanged<PaletteCategory> onCategorySelected;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const _CategorySlotSelector({
    required this.selectedCategory,
    required this.selectedSlot,
    required this.slots,
    required this.colorForSlot,
    required this.onCategorySelected,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedTabBar(
          borderColor: theme.alternatingSurfaceColor,
          selectedIndex: PaletteCategory.values.indexOf(selectedCategory),
          onSelected: (index) =>
              onCategorySelected(PaletteCategory.values[index]),
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
            itemCount: slots.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final slot = slots[index];
              return _SlotPillChip(
                label: slot.label,
                color: colorForSlot(slot),
                selected: slot == selectedSlot,
                onTap: () => onSlotSelected(slot),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ColorStudioCard extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final HSVColor hsv;
  final String hex;
  final Color currentColor;
  final bool canReset;
  final void Function(double hue, double saturation) onHueSaturationChanged;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<String> onHexChanged;
  final VoidCallback onReset;

  const _ColorStudioCard({
    required this.selectedSlot,
    required this.hsv,
    required this.hex,
    required this.currentColor,
    required this.canReset,
    required this.onHueSaturationChanged,
    required this.onValueChanged,
    required this.onHexChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: HsvColorPicker(
        key: ValueKey(selectedSlot),
        hsv: hsv,
        hex: hex,
        currentColor: currentColor,
        canReset: canReset,
        onHueSaturationChanged: onHueSaturationChanged,
        onValueChanged: onValueChanged,
        onHexChanged: onHexChanged,
        onReset: onReset,
      ),
    );
  }
}

class _EditorBottomBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const _EditorBottomBar({required this.onCancel, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _editorMaxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onApply,
                      child: const Text('Применить'),
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
