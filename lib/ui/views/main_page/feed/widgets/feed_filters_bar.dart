// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/feed/feed_filter.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/widgets/segmented_tab_bar.dart';

class FeedFiltersBar extends StatelessWidget {
  final FeedFilter selected;
  final ValueChanged<FeedFilter>? onSelected;
  final Map<FeedFilter, int> unreadCounts;
  final ValueListenable<double?>? position;

  const FeedFiltersBar({
    required this.selected,
    required this.onSelected,
    this.unreadCounts = const {},
    this.position,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            count: unreadCounts[filter],
            countSemanticLabel: '${unreadCounts[filter]} непрочитанных постов',
          ),
      ],
    ),
  );
}
