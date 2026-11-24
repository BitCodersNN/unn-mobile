// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/theme/theme_palette.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/settings_section.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/preview_context_menu.dart';

class ThemePaletteSelector<T extends Enum> extends StatelessWidget
    implements SettingsDividerIndent {
  final String title;
  final T selected;
  final List<ThemePalette<T>> palettes;
  final ValueChanged<int> onSelected;
  final T? customValue;
  final bool isCustomConfigured;
  final VoidCallback? onEditCustom;
  final VoidCallback? onImportCustom;
  final VoidCallback? onShareCustom;

  const ThemePaletteSelector({
    required this.title,
    required this.palettes,
    required this.selected,
    required this.onSelected,
    this.customValue,
    this.isCustomConfigured = false,
    this.onEditCustom,
    this.onImportCustom,
    this.onShareCustom,
    super.key,
  });

  @override
  double get dividerIndent => 16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Используется и при автоматической смене темы системой',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: palettes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final palette = palettes[index];
                final isCustom =
                    customValue != null && palette.value == customValue;
                final isSelected = selected == palette.value;
                final mode = !isCustom
                    ? _PaletteOptionMode.standard
                    : isCustomConfigured
                    ? _PaletteOptionMode.customConfigured
                    : _PaletteOptionMode.customPlaceholder;
                final option = _PaletteOption(
                  label: palette.label,
                  colors: palette.theme.colorScheme,
                  selected: isSelected,
                  mode: mode,
                  onTap: isCustom && !isCustomConfigured
                      ? () => onEditCustom?.call()
                      : isCustom && isSelected && onEditCustom != null
                      ? onEditCustom!
                      : () => onSelected(index),
                );
                return SizedBox(
                  width: 142,
                  child: isCustom
                      ? PreviewContextMenu(
                          borderRadius: BorderRadius.circular(14),
                          actionsBuilder: (_) => [
                            ContextMenuAction.text(
                              label: 'Настроить',
                              leadingIcon: const Icon(Icons.tune_rounded),
                              onTap: onEditCustom,
                            ),
                            ContextMenuAction.text(
                              label: 'Загрузить',
                              leadingIcon: const Icon(Icons.download_rounded),
                              onTap: onImportCustom,
                            ),
                            ContextMenuAction.text(
                              label: 'Поделиться',
                              leadingIcon: const Icon(Icons.share_outlined),
                              enabled:
                                  isCustomConfigured && onShareCustom != null,
                              onTap: onShareCustom,
                            ),
                          ],
                          child: option,
                        )
                      : option,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _PaletteOptionMode { standard, customPlaceholder, customConfigured }

class _PaletteOption extends StatelessWidget {
  final String label;
  final ColorScheme colors;
  final bool selected;
  final VoidCallback onTap;
  final _PaletteOptionMode mode;

  const _PaletteOption({
    required this.label,
    required this.colors,
    required this.selected,
    required this.onTap,
    this.mode = _PaletteOptionMode.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            width: selected ? 2 : 1,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: Column(
            children: [
              ExcludeSemantics(child: _buildPreview(theme)),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) => switch (mode) {
    _PaletteOptionMode.customPlaceholder => Container(
      height: 92,
      color: theme.colorScheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(
        Icons.settings_rounded,
        size: 32,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    ),
    _PaletteOptionMode.customConfigured ||
    _PaletteOptionMode.standard => Container(
      height: 92,
      padding: const EdgeInsets.all(12),
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? colors.primary : colors.outline,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: mode == _PaletteOptionMode.customConfigured
                ? Center(
                    child: Icon(
                      Icons.settings_rounded,
                      size: 28,
                      color: colors.primary,
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.65,
                      child: Container(height: 4, color: colors.primary),
                    ),
                  ),
          ),
        ],
      ),
    ),
  };
}
