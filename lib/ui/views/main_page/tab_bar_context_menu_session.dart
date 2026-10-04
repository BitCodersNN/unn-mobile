import 'package:flutter/widgets.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';

class TabBarContextMenuResult {
  final List<String> paths;
  final bool customize;
  final String? destinationPath;

  TabBarContextMenuResult({
    required Iterable<String> paths,
    this.customize = false,
    this.destinationPath,
  }) : paths = List.unmodifiable(paths);
}

class TabBarContextMenuSession extends ChangeNotifier {
  final Rect barRect;
  final Rect contentRect;
  final TextDirection textDirection;
  final String selectedPath;
  late List<String> _paths;
  late List<String> _beforeDrag;
  late String _heldPath;
  late Offset _pointerOrigin;
  double _dragOffset = 0;
  bool _dragging = false;
  VoidCallback? onDrop;
  VoidCallback? onCancel;

  TabBarContextMenuSession({
    required List<String> paths,
    required this.barRect,
    required Rect anchor,
    required String heldPath,
    required this.selectedPath,
    required Offset pointerOrigin,
    required this.textDirection,
  }) : contentRect = Rect.fromLTWH(
          anchor.left -
              (textDirection == TextDirection.ltr
                      ? paths.indexOf(heldPath)
                      : paths.length - 1 - paths.indexOf(heldPath)) *
                  anchor.width,
          anchor.top,
          anchor.width * paths.length,
          anchor.height,
        ) {
    _paths = List.of(paths);
    begin(heldPath, pointerOrigin);
  }

  List<String> get paths => List.unmodifiable(_paths);
  String get heldPath => _heldPath;
  bool get isDragging => _dragging;
  double get itemWidth => contentRect.width / _paths.length;

  double leftFor(String path) {
    final index = _paths.indexOf(path);
    final physicalIndex =
        textDirection == TextDirection.ltr ? index : _paths.length - 1 - index;
    return contentRect.left + physicalIndex * itemWidth;
  }

  double get draggedLeft {
    final index = _beforeDrag.indexOf(_heldPath);
    final physicalIndex =
        textDirection == TextDirection.ltr ? index : _paths.length - 1 - index;
    return contentRect.left + physicalIndex * itemWidth + _dragOffset;
  }

  void begin(String path, Offset pointerOrigin) {
    _heldPath = path;
    _pointerOrigin = pointerOrigin;
    _beforeDrag = List.of(_paths);
    _dragOffset = 0;
    _dragging = false;
    notifyListeners();
  }

  void move(Offset pointer) {
    if (_heldPath == TabBarPreferences.morePath) {
      return;
    }
    final delta = pointer.dx - _pointerOrigin.dx;
    if (!_dragging && delta.abs() < 8) {
      return;
    }
    _dragging = true;
    final source = _beforeDrag.indexOf(_heldPath);
    final physicalSource = textDirection == TextDirection.ltr
        ? source
        : _paths.length - 1 - source;
    final firstEditable = textDirection == TextDirection.ltr ? 0 : 1;
    final lastEditable = textDirection == TextDirection.ltr
        ? _paths.length - 2
        : _paths.length - 1;
    final center = (physicalSource * itemWidth + itemWidth / 2 + delta).clamp(
      firstEditable * itemWidth + itemWidth / 2,
      lastEditable * itemWidth + itemWidth / 2,
    );
    _dragOffset = center - physicalSource * itemWidth - itemWidth / 2;
    final physicalTarget =
        (center / itemWidth).floor().clamp(firstEditable, lastEditable);
    final target = textDirection == TextDirection.ltr
        ? physicalTarget
        : _paths.length - 1 - physicalTarget;
    _paths = TabBarPreferences.reordered(_beforeDrag, source, target);
    notifyListeners();
  }

  void end() {
    if (!_dragging) {
      return;
    }
    _dragging = false;
    notifyListeners();
    onDrop?.call();
  }
}
