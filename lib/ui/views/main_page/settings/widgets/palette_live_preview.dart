// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/base_mini_screens_preview.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/category_previews.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

class PaletteLivePreview extends StatefulWidget {
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
  State<PaletteLivePreview> createState() => _PaletteLivePreviewState();
}

class _PaletteLivePreviewState extends State<PaletteLivePreview> {
  static const _basePageTitles = [
    'Лента',
    'Зачётка',
    'Расписание',
    'Настройки',
  ];

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageDotTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewTheme = widget.previewTheme;
    final colors = previewTheme.colorScheme;
    final isSurfaceSelected = widget.selectedSlot == PaletteColorSlot.surface;
    final isBase = widget.selectedCategory == PaletteCategory.base;

    return Theme(
      data: previewTheme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSurfaceSelected
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.6),
              width: isSurfaceSelected ? 1.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: switch (widget.selectedCategory) {
                      PaletteCategory.base => BaseCategoryPreview(
                        key: const ValueKey(PaletteCategory.base),
                        pageController: _pageController,
                        selectedSlot: widget.selectedSlot,
                        onSlotSelected: widget.onSlotSelected,
                        onPageChanged: (index) {
                          if (_currentPage != index) {
                            setState(() => _currentPage = index);
                          }
                        },
                      ),
                      PaletteCategory.schedule => CenteredStageScroll(
                        key: const ValueKey(PaletteCategory.schedule),
                        onBackgroundTap: () =>
                            widget.onSlotSelected(PaletteColorSlot.surface),
                        child: ScheduleCategoryPreview(
                          selectedSlot: widget.selectedSlot,
                          onSlotSelected: widget.onSlotSelected,
                        ),
                      ),
                      PaletteCategory.grades => CenteredStageScroll(
                        key: const ValueKey(PaletteCategory.grades),
                        onBackgroundTap: () =>
                            widget.onSlotSelected(PaletteColorSlot.surface),
                        child: GradesCategoryPreview(
                          selectedSlot: widget.selectedSlot,
                          onSlotSelected: widget.onSlotSelected,
                        ),
                      ),
                      PaletteCategory.effects => CenteredStageScroll(
                        key: const ValueKey(PaletteCategory.effects),
                        onBackgroundTap: () =>
                            widget.onSlotSelected(PaletteColorSlot.surface),
                        child: EffectsCategoryPreview(
                          selectedSlot: widget.selectedSlot,
                          onSlotSelected: widget.onSlotSelected,
                        ),
                      ),
                    },
                  ),
                ),
                PreviewStatusFooter(
                  slotLabel: widget.selectedSlot.label,
                  slotColor: widget.selectedSlotColor,
                  pageTitle: isBase ? _basePageTitles[_currentPage] : null,
                  pageCount: isBase ? _basePageTitles.length : 0,
                  currentPage: _currentPage,
                  onPageTap: isBase ? _onPageDotTap : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
