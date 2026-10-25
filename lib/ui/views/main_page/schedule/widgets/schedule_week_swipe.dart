// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/swipe_pager.dart';

class ScheduleWeekSwipe extends StatefulWidget {
  final int weekOffset;
  final IndexedWidgetBuilder weekBuilder;
  final ValueChanged<int> onWeekChanged;
  final bool enabled;

  const ScheduleWeekSwipe({
    required this.weekOffset,
    required this.weekBuilder,
    required this.onWeekChanged,
    super.key,
    this.enabled = true,
  });

  @override
  State<ScheduleWeekSwipe> createState() => _ScheduleWeekSwipeState();
}

class _ScheduleWeekSwipeState extends State<ScheduleWeekSwipe> {
  // Запас индексов для перелистывания к предыдущим неделям.
  static const int _initialPageIndex = 1000000;
  late final int _anchorWeekOffset;

  @override
  void initState() {
    super.initState();
    _anchorWeekOffset = widget.weekOffset;
  }

  @override
  Widget build(BuildContext context) => SwipePager(
        selectedPage: _initialPageIndex + widget.weekOffset - _anchorWeekOffset,
        enabled: widget.enabled,
        onUserPageChanged: (page) => widget.onWeekChanged(
          _anchorWeekOffset + page - _initialPageIndex,
        ),
        itemBuilder: (context, page) {
          final weekOffset = _anchorWeekOffset + page - _initialPageIndex;
          return KeyedSubtree(
            key: ValueKey(weekOffset),
            child: widget.weekBuilder(context, weekOffset),
          );
        },
      );
}
