// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/theme/palette_slot_labels.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/base_category_preview.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/centered_stage_scroll.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/effects_category_preview.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/grades_category_preview.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/preview_status_footer.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/schedule_category_preview.dart';

class PaletteLivePreview extends StatelessWidget {
  final ThemeData previewTheme;
  final PaletteCategory selectedCategory;
  final PaletteColorSlot selectedSlot;
  final Color selectedSlotColor;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const PaletteLivePreview({
    required this.previewTheme,
    required this.selectedCategory,
    required this.selectedSlot,
    required this.selectedSlotColor,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = previewTheme.colorScheme;
    final isSurfaceSelected = selectedSlot == PaletteColorSlot.surface;

    return Theme(
      data: previewTheme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(MiniPreviewStyle.outerRadius),
          boxShadow: [
            BoxShadow(
              color: previewTheme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            if (isSurfaceSelected)
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.18),
                blurRadius: 12,
                spreadRadius: 1,
              ),
          ],
        ),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MiniPreviewStyle.outerRadius),
            border: Border.all(
              color: isSurfaceSelected
                  ? colors.primary
                  : colors.outlineVariant.withValues(
                      alpha: MiniPreviewStyle.outerBorderAlpha,
                    ),
              width: isSurfaceSelected ? 1.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              MiniPreviewStyle.innerClipRadius,
            ),
            child: AnimatedSwitcher(
              duration: MiniPreviewStyle.categorySwitchDuration,
              child: switch (selectedCategory) {
                PaletteCategory.base => BaseCategoryPreview(
                  key: const ValueKey(PaletteCategory.base),
                  selectedSlot: selectedSlot,
                  selectedSlotColor: selectedSlotColor,
                  onSlotSelected: onSlotSelected,
                ),
                PaletteCategory.schedule => ScheduleCategoryPreview(
                  key: const ValueKey(PaletteCategory.schedule),
                  selectedSlot: selectedSlot,
                  selectedSlotColor: selectedSlotColor,
                  onSlotSelected: onSlotSelected,
                ),
                PaletteCategory.grades => _StaticCategoryPreview(
                  key: const ValueKey(PaletteCategory.grades),
                  slotLabel: selectedSlot.label,
                  slotColor: selectedSlotColor,
                  onBackgroundTap: () =>
                      onSlotSelected(PaletteColorSlot.surface),
                  child: GradesCategoryPreview(
                    selectedSlot: selectedSlot,
                    onSlotSelected: onSlotSelected,
                  ),
                ),
                PaletteCategory.effects => _StaticCategoryPreview(
                  key: const ValueKey(PaletteCategory.effects),
                  slotLabel: selectedSlot.label,
                  slotColor: selectedSlotColor,
                  onBackgroundTap: () =>
                      onSlotSelected(PaletteColorSlot.surface),
                  child: EffectsCategoryPreview(
                    selectedSlot: selectedSlot,
                    onSlotSelected: onSlotSelected,
                  ),
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticCategoryPreview extends StatelessWidget {
  final String slotLabel;
  final Color slotColor;
  final VoidCallback onBackgroundTap;
  final Widget child;

  const _StaticCategoryPreview({
    required this.slotLabel,
    required this.slotColor,
    required this.onBackgroundTap,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: CenteredStageScroll(
          onBackgroundTap: onBackgroundTap,
          child: child,
        ),
      ),
      PreviewStatusFooter(slotLabel: slotLabel, slotColor: slotColor),
    ],
  );
}
