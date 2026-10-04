// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_drag_controller.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_drag_feedback.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_gesture_detector.dart';

class TabBarReorderPreview extends StatefulWidget {
  final int itemCount;
  final Object Function(int index) itemKey;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool Function(int index) canDrag;
  final bool Function(int from, int to) canMove;
  final ValueChanged<int> onSelected;
  final void Function(int from, int to) onMove;

  const TabBarReorderPreview({
    required this.itemCount,
    required this.itemKey,
    required this.itemBuilder,
    required this.canDrag,
    required this.canMove,
    required this.onSelected,
    required this.onMove,
    super.key,
  });

  @override
  State<TabBarReorderPreview> createState() => _TabBarReorderPreviewState();
}

class _TabBarReorderPreviewState extends State<TabBarReorderPreview> {
  late TabBarDragController _drag;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    _drag = TabBarDragController(
      itemCount: widget.itemCount,
      editableCount: widget.itemCount - 1,
    )..addListener(_onDragChanged);
  }

  void _onDragChanged() => setState(() {});

  @override
  void didUpdateWidget(TabBarReorderPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _drag.dispose();
      _createController();
    }
  }

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  void _begin(int index, Offset pointer) {
    _drag.begin(index, pointer.dx);
    widget.onSelected(index);
  }

  void _end() {
    final move = _drag.finish();
    if (move != null && widget.canMove(move.from, move.to)) {
      widget.onMove(move.from, move.to);
    }
    _drag.cancel();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 62,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / widget.itemCount;
            final direction = Directionality.of(context);
            final visualOrder = _drag.visualOrder;
            Widget item(int index) {
              final dragging = _drag.isDragging && index == _drag.heldIndex;
              final visualIndex = visualOrder.indexOf(index);
              final physicalIndex = _drag.physicalIndex(visualIndex, direction);
              return AnimatedPositioned(
                key: ValueKey(widget.itemKey(index)),
                duration: dragging
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                left: dragging
                    ? _drag.draggedLeft(itemWidth, direction)
                    : physicalIndex * itemWidth,
                top: dragging ? -8 : 0,
                width: itemWidth,
                height: 62,
                child: TabBarGestureDetector(
                  onHoldStart: widget.canDrag(index)
                      ? (pointer) => _begin(index, pointer)
                      : null,
                  onHoldMove: (pointer) => _drag.update(
                    pointerX: pointer.dx,
                    itemWidth: itemWidth,
                    direction: direction,
                    canMove: widget.canMove,
                  ),
                  onHoldEnd: _end,
                  onHoldCancel: _drag.cancel,
                  child: TabBarDragFeedback(
                    dragging: dragging,
                    backgroundColor: index == _drag.heldIndex
                        ? TabBarDragFeedback.highlightColor(context)
                        : Colors.transparent,
                    child: widget.itemBuilder(context, index),
                  ),
                ),
              );
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (var index = 0; index < widget.itemCount; index++)
                  if (!_drag.isDragging || index != _drag.heldIndex)
                    item(index),
                if (_drag.isDragging) item(_drag.heldIndex!),
              ],
            );
          },
        ),
      );
}
