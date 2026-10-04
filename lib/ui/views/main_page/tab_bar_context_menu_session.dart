import 'package:flutter/widgets.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_drag_controller.dart';

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
  final TabBarDragController _drag;
  List<String> _basePaths;
  bool _closeRequested = false;
  TabBarContextMenuResult? _result;

  TabBarContextMenuSession({
    required List<String> paths,
    required this.barRect,
    required Rect anchor,
    required String heldPath,
    required this.selectedPath,
    required Offset pointerOrigin,
    required this.textDirection,
  })  : _basePaths = List.unmodifiable(paths),
        _drag = TabBarDragController(
          itemCount: paths.length,
          editableCount: paths.length - 1,
        ),
        contentRect = Rect.fromLTWH(
          anchor.left -
              (textDirection == TextDirection.ltr
                      ? paths.indexOf(heldPath)
                      : paths.length - 1 - paths.indexOf(heldPath)) *
                  anchor.width,
          anchor.top,
          anchor.width * paths.length,
          anchor.height,
        ) {
    _drag.addListener(notifyListeners);
    begin(heldPath, pointerOrigin);
  }

  List<String> get paths =>
      List.unmodifiable(_drag.visualOrder.map((index) => _basePaths[index]));
  String get heldPath => _basePaths[_drag.heldIndex!];
  bool get isDragging => _drag.isDragging;
  bool get closeRequested => _closeRequested;
  TabBarContextMenuResult? get result => _result;
  double get itemWidth => contentRect.width / _basePaths.length;
  double get draggedLeft =>
      contentRect.left + _drag.draggedLeft(itemWidth, textDirection);

  double leftFor(String path) =>
      contentRect.left +
      _drag.physicalIndex(paths.indexOf(path), textDirection) * itemWidth;

  void begin(String path, Offset pointerOrigin) {
    if (_closeRequested) {
      return;
    }
    final currentPaths = paths;
    final index = currentPaths.indexOf(path);
    _basePaths = currentPaths;
    _drag.begin(index, pointerOrigin.dx);
  }

  void move(Offset pointer) {
    if (_closeRequested) {
      return;
    }
    _drag.update(
      pointerX: pointer.dx,
      itemWidth: itemWidth,
      direction: textDirection,
    );
  }

  void end() {
    if (_closeRequested || _drag.finish() == null) {
      return;
    }
    _result = TabBarContextMenuResult(paths: paths);
    _closeRequested = true;
    notifyListeners();
  }

  void cancel() {
    if (_closeRequested) {
      return;
    }
    _closeRequested = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }
}
