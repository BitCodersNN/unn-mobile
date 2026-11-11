// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/feed/feed_filter.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/widgets/count_badge.dart';
import 'package:unn_mobile/ui/widgets/segmented_tab_bar.dart';

class FeedFiltersBar extends StatelessWidget {
  final FeedFilter selected;
  final ValueChanged<FeedFilter>? onSelected;
  final Map<FeedFilter, int> unreadCounts;
  final int? pinnedPostCount;
  final ValueListenable<double?>? position;

  const FeedFiltersBar({
    required this.selected,
    required this.onSelected,
    this.unreadCounts = const {},
    this.pinnedPostCount,
    this.position,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
    child: SegmentedTabBar(
      borderColor: Theme.of(context).alternatingSurfaceColor,
      selectedIndex: FeedFilter.values.indexOf(selected),
      onSelected: onSelected == null
          ? null
          : (index) => onSelected!(FeedFilter.values[index]),
      position: position,
      items: [
        for (final filter in FeedFilter.values)
          SegmentedTabItem(
            label: filter.caption,
            count: filter == FeedFilter.pinned
                ? pinnedPostCount
                : unreadCounts[filter],
            countSemanticLabel: filter == FeedFilter.pinned
                ? '$pinnedPostCount закреплённых постов'
                : '${unreadCounts[filter]} непрочитанных постов',
            countTone: filter == FeedFilter.pinned
                ? CountBadgeTone.neutral
                : CountBadgeTone.accent,
          ),
      ],
    ),
  );
}
