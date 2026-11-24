// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class SettingsMiniScreenBody extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const SettingsMiniScreenBody({
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SlotHighlight(
              active: selectedSlot == PaletteColorSlot.cardSurface,
              borderRadius: BorderRadius.circular(
                MiniPreviewStyle.compactRadius,
              ),
              onTap: () => onSlotSelected(PaletteColorSlot.cardSurface),
              child: MiniSurfaceCard(
                padding: EdgeInsets.zero,
                borderRadius: MiniPreviewStyle.compactRadius,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniSettingsRow(
                      icon: Icons.notifications_outlined,
                      title: 'Уведомления',
                      subtitle: 'Новые записи в ленте',
                      selectedSlot: selectedSlot,
                      highlightDetails: true,
                      onSlotSelected: onSlotSelected,
                    ),
                    HighlightedSlotDivider(
                      selectedSlot: selectedSlot,
                      onSlotSelected: onSlotSelected,
                      borderRadius: MiniPreviewStyle.barRadius,
                    ),
                    _MiniSettingsRow(
                      icon: Icons.vibration_rounded,
                      title: 'Вибрация',
                      subtitle: 'Тактильный отклик',
                      selectedSlot: selectedSlot,
                      highlightDetails: false,
                      onSlotSelected: onSlotSelected,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SlotHighlight(
              active: selectedSlot == PaletteColorSlot.primary,
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSlotSelected(PaletteColorSlot.primary),
              child: SizedBox(
                height: 30,
                child: FilledButton(
                  onPressed: () => onSlotSelected(PaletteColorSlot.primary),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Сохранить'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final PaletteColorSlot selectedSlot;
  final bool highlightDetails;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const _MiniSettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selectedSlot,
    required this.highlightDetails,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          SlotHighlight(
            active:
                highlightDetails && selectedSlot == PaletteColorSlot.primary,
            borderRadius: BorderRadius.circular(MiniPreviewStyle.pillRadius),
            onTap: () => onSlotSelected(PaletteColorSlot.primary),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(icon, size: 16, color: colors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HighlightedSlotText(
                  text: title,
                  slot: PaletteColorSlot.onSurface,
                  selectedSlot: selectedSlot,
                  onSlotSelected: onSlotSelected,
                  enabled: highlightDetails,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: MiniPreviewStyle.fontSizeSubhead,
                  ),
                ),
                HighlightedSlotText(
                  text: subtitle,
                  slot: PaletteColorSlot.onSurfaceVariant,
                  selectedSlot: selectedSlot,
                  onSlotSelected: onSlotSelected,
                  enabled: highlightDetails,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: MiniPreviewStyle.fontSizeCaption,
                  ),
                ),
              ],
            ),
          ),
          SlotHighlight(
            active:
                highlightDetails && selectedSlot == PaletteColorSlot.primary,
            borderRadius: BorderRadius.circular(MiniPreviewStyle.cardRadius),
            onTap: () => onSlotSelected(PaletteColorSlot.primary),
            child: SizedBox(
              height: 22,
              child: FittedBox(
                child: Switch(
                  value: true,
                  onChanged: (_) => onSlotSelected(PaletteColorSlot.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
