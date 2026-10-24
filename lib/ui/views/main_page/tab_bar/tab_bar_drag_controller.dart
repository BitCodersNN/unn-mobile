// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/widgets.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';

class TabBarMove {
  final int from;
  final int to;

  const TabBarMove(this.from, this.to);
}

class TabBarDragController extends ChangeNotifier {
  final int itemCount;
  final int editableCount;
  int? _source;
  int? _target;
  double _pointerOrigin = 0;
  double _offset = 0;
  bool _dragging = false;

  TabBarDragController({required this.itemCount, required this.editableCount})
      : assert(editableCount > 0 && editableCount <= itemCount);

  int? get heldIndex => _source;
  bool get isDragging => _dragging;

  List<int> get visualOrder {
    final indices = List<int>.generate(itemCount, (index) => index);
    return _source == null || _target == null
        ? List.unmodifiable(indices)
        : TabBarPreferences.reordered(indices, _source!, _target!);
  }

  int physicalIndex(int index, TextDirection direction) =>
      direction == TextDirection.ltr ? index : itemCount - 1 - index;

  double draggedLeft(double itemWidth, TextDirection direction) =>
      physicalIndex(_source!, direction) * itemWidth + _offset;

  void begin(int index, double pointerX) {
    if (index < 0 || index >= itemCount) {
      throw RangeError.range(index, 0, itemCount - 1, 'index');
    }
    _source = index;
    _target = index;
    _pointerOrigin = pointerX;
    _offset = 0;
    _dragging = false;
    notifyListeners();
  }

  void update({
    required double pointerX,
    required double itemWidth,
    required TextDirection direction,
    bool Function(int from, int to)? canMove,
  }) {
    final source = _source;
    if (source == null || source >= editableCount || itemWidth <= 0) {
      return;
    }
    final delta = pointerX - _pointerOrigin;
    if (!_dragging && delta.abs() < 8) {
      return;
    }
    final physicalSource = physicalIndex(source, direction);
    final first = physicalIndex(
      direction == TextDirection.ltr ? 0 : editableCount - 1,
      direction,
    );
    final last = physicalIndex(
      direction == TextDirection.ltr ? editableCount - 1 : 0,
      direction,
    );
    final center = (physicalSource * itemWidth + itemWidth / 2 + delta).clamp(
      first * itemWidth + itemWidth / 2,
      last * itemWidth + itemWidth / 2,
    );
    final physicalTarget = (center / itemWidth).floor().clamp(first, last);
    final target = physicalIndex(physicalTarget, direction);
    final accepted =
        target == source || (canMove?.call(source, target) ?? true);
    final offset = center - physicalSource * itemWidth - itemWidth / 2;
    final nextTarget = accepted ? target : source;
    if (_dragging && _offset == offset && _target == nextTarget) {
      return;
    }
    _dragging = true;
    _offset = offset;
    _target = nextTarget;
    notifyListeners();
  }

  TabBarMove? finish() {
    if (!_dragging) {
      return null;
    }
    final move = TabBarMove(_source!, _target!);
    _dragging = false;
    notifyListeners();
    return move;
  }

  void cancel() {
    _source = null;
    _target = null;
    _offset = 0;
    _dragging = false;
    notifyListeners();
  }
}
