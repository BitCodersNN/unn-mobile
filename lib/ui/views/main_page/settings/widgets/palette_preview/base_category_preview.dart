// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/theme/palette_slot_labels.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/feed_mini_preview.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/grades_mini_preview.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/paged_category_preview.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/schedule_mini_preview.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/settings_mini_preview.dart';

class BaseCategoryPreview extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final Color selectedSlotColor;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const BaseCategoryPreview({
    required this.selectedSlot,
    required this.selectedSlotColor,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void onBackgroundTap() => onSlotSelected(PaletteColorSlot.surface);
    return PagedCategoryPreview(
      slotLabel: selectedSlot.label,
      slotColor: selectedSlotColor,
      pages: [
        PreviewPage(
          title: 'Лента',
          child: MiniScreenFrame(
            appBar: const MiniAppBar(title: 'Лента'),
            onBackgroundTap: onBackgroundTap,
            body: FeedMiniScreenBody(
              selectedSlot: selectedSlot,
              onSlotSelected: onSlotSelected,
            ),
            bottomBar: MiniBottomNavBar(
              activeIndex: 0,
              selectedSlot: selectedSlot,
              onSlotSelected: onSlotSelected,
            ),
          ),
        ),
        PreviewPage(
          title: 'Зачётка',
          child: MiniScreenFrame(
            appBar: const MiniAppBar(title: 'Зачётная книжка'),
            onBackgroundTap: onBackgroundTap,
            body: GradesMiniScreenBody(
              selectedSlot: selectedSlot,
              onSlotSelected: onSlotSelected,
            ),
            bottomBar: MiniBottomNavBar(
              activeIndex: 2,
              selectedSlot: selectedSlot,
              onSlotSelected: onSlotSelected,
            ),
          ),
        ),
        PreviewPage(
          title: 'Расписание',
          child: MiniScreenFrame(
            appBar: const MiniAppBar(title: 'Расписание'),
            onBackgroundTap: onBackgroundTap,
            body: ScheduleMiniScreenBody(
              selectedSlot: selectedSlot,
              onSlotSelected: onSlotSelected,
            ),
            bottomBar: MiniBottomNavBar(
              activeIndex: 1,
              selectedSlot: selectedSlot,
              onSlotSelected: onSlotSelected,
            ),
          ),
        ),
        PreviewPage(
          title: 'Настройки',
          child: MiniScreenFrame(
            appBar: const MiniAppBar(title: 'Настройки'),
            onBackgroundTap: onBackgroundTap,
            body: SettingsMiniScreenBody(
              selectedSlot: selectedSlot,
              onSlotSelected: onSlotSelected,
            ),
          ),
        ),
      ],
    );
  }
}
