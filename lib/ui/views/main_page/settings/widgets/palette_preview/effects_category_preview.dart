// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class EffectsCategoryPreview extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const EffectsCategoryPreview({
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final extra = theme.unnMobileColors;
    final baseColor = extra?.shimmerBaseColor ?? colors.surfaceContainer;
    final highlightColor =
        extra?.shimmerHighlightColor ?? colors.surfaceContainerHighest;
    final gradient = LinearGradient(
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.15, 0.5, 0.85],
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: MiniSurfaceCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SlotHighlight(
              active:
                  selectedSlot == PaletteColorSlot.shimmerBase ||
                  selectedSlot == PaletteColorSlot.shimmerHighlight,
              borderRadius: BorderRadius.circular(
                MiniPreviewStyle.mediumRadius,
              ),
              onTap: () => onSlotSelected(
                selectedSlot == PaletteColorSlot.shimmerBase
                    ? PaletteColorSlot.shimmerHighlight
                    : PaletteColorSlot.shimmerBase,
              ),
              child: Container(
                height: 22,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(
                    MiniPreviewStyle.mediumRadius,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SlotHighlight(
                  active: selectedSlot == PaletteColorSlot.shimmerBase,
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onSlotSelected(PaletteColorSlot.shimmerBase),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SlotHighlight(
                        active:
                            selectedSlot == PaletteColorSlot.shimmerHighlight,
                        borderRadius: BorderRadius.circular(
                          MiniPreviewStyle.pillRadius,
                        ),
                        onTap: () =>
                            onSlotSelected(PaletteColorSlot.shimmerHighlight),
                        child: Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: highlightColor,
                            borderRadius: BorderRadius.circular(
                              MiniPreviewStyle.pillRadius,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FractionallySizedBox(
                        widthFactor: 0.65,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(
                              MiniPreviewStyle.pillRadius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
