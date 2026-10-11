// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';

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
  static const int _originPage = 1000000;
  late final int _anchorWeekOffset;
  late final PageController _pages;
  int _currentPage = _originPage;
  int? _programmaticPage;

  @override
  void initState() {
    super.initState();
    _anchorWeekOffset = widget.weekOffset;
    _pages = PageController(initialPage: _originPage);
  }

  @override
  void didUpdateWidget(ScheduleWeekSwipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weekOffset == widget.weekOffset) {
      return;
    }
    final page = _originPage + widget.weekOffset - _anchorWeekOffset;
    if (page != _currentPage) {
      _programmaticPage = page;
      unawaited(_animateToPage(page));
    }
  }

  Future<void> _animateToPage(int page) async {
    await _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    if (mounted && _programmaticPage == page) {
      setState(() => _programmaticPage = null);
    }
  }

  void _onPageChanged(int page) {
    _currentPage = page;
    if (_programmaticPage == null) {
      widget.onWeekChanged(_anchorWeekOffset + page - _originPage);
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageView.builder(
        controller: _pages,
        physics: widget.enabled && _programmaticPage == null
            ? null
            : const NeverScrollableScrollPhysics(),
        onPageChanged: _onPageChanged,
        itemBuilder: (context, page) {
          final weekOffset = _anchorWeekOffset + page - _originPage;
          return KeyedSubtree(
            key: ValueKey(weekOffset),
            child: widget.weekBuilder(context, weekOffset),
          );
        },
      );
}
