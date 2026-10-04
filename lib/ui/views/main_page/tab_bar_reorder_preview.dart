import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_drag_feedback.dart';

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
  int? _source;
  int? _target;
  Offset _pointerOrigin = Offset.zero;
  double _dragOffset = 0;
  bool _dragging = false;

  void _begin(int index, Offset pointer) {
    setState(() {
      _source = index;
      _target = index;
      _pointerOrigin = pointer;
      _dragOffset = 0;
      _dragging = false;
    });
    widget.onSelected(index);
  }

  void _move(Offset pointer, double itemWidth, TextDirection direction) {
    final source = _source;
    if (source == null) {
      return;
    }
    final delta = pointer.dx - _pointerOrigin.dx;
    if (!_dragging && delta.abs() < 8) {
      return;
    }
    final physicalSource =
        direction == TextDirection.ltr ? source : widget.itemCount - 1 - source;
    final first = direction == TextDirection.ltr ? 0 : 1;
    final last = direction == TextDirection.ltr
        ? widget.itemCount - 2
        : widget.itemCount - 1;
    final center = (physicalSource * itemWidth + itemWidth / 2 + delta).clamp(
      first * itemWidth + itemWidth / 2,
      last * itemWidth + itemWidth / 2,
    );
    final physicalTarget = (center / itemWidth).floor().clamp(first, last);
    final target = direction == TextDirection.ltr
        ? physicalTarget
        : widget.itemCount - 1 - physicalTarget;
    setState(() {
      _dragging = true;
      _dragOffset = center - physicalSource * itemWidth - itemWidth / 2;
      _target =
          target == source || widget.canMove(source, target) ? target : source;
    });
  }

  void _end() {
    final source = _source;
    final target = _target;
    if (_dragging &&
        source != null &&
        target != null &&
        widget.canMove(source, target)) {
      widget.onMove(source, target);
    }
    _cancel();
  }

  void _cancel() => setState(() {
        _source = null;
        _target = null;
        _dragOffset = 0;
        _dragging = false;
      });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 62,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / widget.itemCount;
            final direction = Directionality.of(context);
            final indices =
                List<int>.generate(widget.itemCount, (index) => index);
            final visualOrder = _dragging
                ? TabBarPreferences.reordered(indices, _source!, _target!)
                : indices;
            Widget item(int index) {
              final dragging = _dragging && index == _source;
              final visualIndex = visualOrder.indexOf(index);
              final physicalIndex = direction == TextDirection.ltr
                  ? visualIndex
                  : widget.itemCount - 1 - visualIndex;
              final physicalSource = direction == TextDirection.ltr
                  ? index
                  : widget.itemCount - 1 - index;
              return AnimatedPositioned(
                key: ValueKey(widget.itemKey(index)),
                duration: dragging
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                left: dragging
                    ? physicalSource * itemWidth + _dragOffset
                    : physicalIndex * itemWidth,
                top: dragging ? -8 : 0,
                width: itemWidth,
                height: 62,
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  gestures: widget.canDrag(index)
                      ? {
                          LongPressGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                  LongPressGestureRecognizer>(
                            () => LongPressGestureRecognizer(
                              duration: const Duration(milliseconds: 350),
                            ),
                            (recognizer) => recognizer
                              ..onLongPressStart = ((details) =>
                                  _begin(index, details.globalPosition))
                              ..onLongPressMoveUpdate = ((details) => _move(
                                    details.globalPosition,
                                    itemWidth,
                                    direction,
                                  ))
                              ..onLongPressEnd = ((_) => _end())
                              ..onLongPressCancel = _cancel,
                          ),
                        }
                      : {},
                  child: TabBarDragFeedback(
                    dragging: dragging,
                    backgroundColor: index == _source
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
                  if (!_dragging || index != _source) item(index),
                if (_dragging) item(_source!),
              ],
            );
          },
        ),
      );
}
