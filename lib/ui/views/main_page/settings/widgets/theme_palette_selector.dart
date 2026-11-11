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

  const ThemePaletteSelector({
    required this.title,
    required this.palettes,
    required this.selected,
    required this._onChanged,
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
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 280 ? 1 : 2;
              final width =
                  (constraints.maxWidth - 12 * (columns - 1)) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final palette in palettes)
                    SizedBox(
                      width: width,
                      child: _PaletteOption(
                        label: palette.label,
                        colors: palette.theme.colorScheme,
                        selected: selected == palette.value,
                        onTap: () => _onChanged(palette.value),
                      ),
                    ),
                ],
              );
            },
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
  final VoidCallback onTap;

  const _PaletteOption({
    required this.label,
    required this.colors,
    required this.selected,
    required this.onTap,
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
              ExcludeSemantics(
                child: Container(
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
                          color: selected ? colors.primary : colors.outline,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 10,
                ),
                child: Text(label, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
