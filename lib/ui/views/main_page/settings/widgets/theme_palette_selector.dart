// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/theme/theme_palette.dart';

class ThemePaletteSelector<T extends Enum> extends StatelessWidget {
  final String title;
  final T selected;
  final List<ThemePalette<T>> palettes;
  // Обработчик вызывается только с T из списка палитр этого компонента.
  // ignore: unsafe_variance
  final ValueChanged<T> _onChanged;
  final T? customValue;
  final bool isCustomConfigured;
  final VoidCallback? onEditCustom;

  const ThemePaletteSelector({
    required this.title,
    required this.palettes,
    required this.selected,
    required this._onChanged,
    this.customValue,
    this.isCustomConfigured = false,
    this.onEditCustom,
    super.key,
  });

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
                return SizedBox(
                  width: 142,
                  child: _PaletteOption(
                    label: palette.label,
                    colors: palette.theme.colorScheme,
                    selected: isSelected,
                    showGearPlaceholder: isCustom && !isCustomConfigured,
                    showGearInsteadOfCard: isCustom && isCustomConfigured,
                    onTap: isCustom && !isCustomConfigured
                        ? () => onEditCustom?.call()
                        : isCustom && isSelected && onEditCustom != null
                        ? onEditCustom!
                        : () => _onChanged(palette.value),
                    onLongPress: isCustom ? onEditCustom : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteOption extends StatelessWidget {
  final String label;
  final ColorScheme colors;
  final bool selected;
  final bool showGearPlaceholder;
  final bool showGearInsteadOfCard;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _PaletteOption({
    required this.label,
    required this.colors,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.showGearPlaceholder = false,
    this.showGearInsteadOfCard = false,
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
          onLongPress: onLongPress,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: Column(
            children: [
              ExcludeSemantics(
                child: showGearPlaceholder
                    ? Container(
                        height: 92,
                        color: theme.colorScheme.surfaceContainerHigh,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.settings_rounded,
                          size: 32,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Container(
                        height: 92,
                        padding: const EdgeInsets.all(12),
                        color: colors.surface,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: selected
                                    ? colors.primary
                                    : colors.outline,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: showGearInsteadOfCard
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
                                        child: Container(
                                          height: 4,
                                          color: colors.primary,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
              ),
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
}
