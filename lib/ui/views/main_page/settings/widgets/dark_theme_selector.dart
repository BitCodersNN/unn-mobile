// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/ui/theme/app_theme.dart';

class DarkThemeSelector extends StatelessWidget {
  final AppDarkTheme selected;
  final ValueChanged<AppDarkTheme> onChanged;

  const DarkThemeSelector({
    required this.selected,
    required this.onChanged,
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
          Text('Тёмная палитра', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Используется и при автоматической смене темы системой',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              for (final palette in AppDarkTheme.values)
                Expanded(
                  child: _PaletteOption(
                    palette: palette,
                    selected: selected == palette,
                    onTap: () => onChanged(palette),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaletteOption extends StatelessWidget {
  final AppDarkTheme palette;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteOption({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppTheme.darkThemeFor(palette).colorScheme;
    final label = switch (palette) {
      AppDarkTheme.green => 'Зелёная',
      AppDarkTheme.graphite => 'Графитовая',
    };
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
