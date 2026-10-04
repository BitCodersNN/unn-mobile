// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class ScheduleWeekSwipe extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const ScheduleWeekSwipe({
    required this.child,
    required this.onPreviousWeek,
    required this.onNextWeek,
    super.key,
    this.enabled = true,
  });

  @override
  State<ScheduleWeekSwipe> createState() => _ScheduleWeekSwipeState();
}

class _ScheduleWeekSwipeState extends State<ScheduleWeekSwipe> {
  double _dragDistance = 0;
  double _offset = 0;
  bool _isDragging = false;

  @override
  void didUpdateWidget(ScheduleWeekSwipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) {
      _isDragging = false;
      _offset = 0;
      _dragDistance = 0;
    }
  }

  void _resetDrag() => setState(() {
        _isDragging = false;
        _offset = 0;
      });

  void _onDragEnd(DragEndDetails details) {
    _resetDrag();
    if (!widget.enabled) {
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    final isFling = velocity.abs() >= 500 && _dragDistance.abs() >= 20;
    if (!isFling && _dragDistance.abs() < 48) {
      return;
    }

    final direction = isFling ? velocity : _dragDistance;
    if (direction < 0) {
      widget.onNextWeek();
    } else {
      widget.onPreviousWeek();
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: widget.enabled
              ? (_) {
                  _dragDistance = 0;
                  setState(() => _isDragging = true);
                }
              : null,
          onHorizontalDragUpdate: widget.enabled
              ? (details) {
                  _dragDistance += details.primaryDelta ?? 0;
                  setState(() {
                    _offset = (_dragDistance * 0.35).clamp(
                      -constraints.maxWidth * 0.15,
                      constraints.maxWidth * 0.15,
                    );
                  });
                }
              : null,
          onHorizontalDragEnd: widget.enabled ? _onDragEnd : null,
          onHorizontalDragCancel: widget.enabled ? _resetDrag : null,
          child: ClipRect(
            child: AnimatedContainer(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(_offset, 0, 0),
              child: widget.child,
            ),
          ),
        ),
      );
}
