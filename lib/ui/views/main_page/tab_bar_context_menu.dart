import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_context_menu_session.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_drag_feedback.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_gesture_detector.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar_item_content.dart';

Future<TabBarContextMenuResult?> showTabBarContextMenu(
  BuildContext context, {
  required TabBarContextMenuSession session,
  required List<MainPageRouteData> routes,
}) {
  final completion = Completer<TabBarContextMenuResult?>();
  late final OverlayEntry entry;
  LocalHistoryEntry? history;
  TabBarContextMenuResult? dismissedResult;
  var removed = false;
  void removeOverlay() {
    if (removed) {
      return;
    }
    removed = true;
    history?.remove();
    entry
      ..remove()
      ..dispose();
  }

  entry = OverlayEntry(
    builder: (_) => _TabBarContextMenu(
      session: session,
      routes: routes,
      onDismiss: (result) {
        dismissedResult = result;
        removeOverlay();
      },
      onClosed: () {
        removeOverlay();
        completion.complete(dismissedResult);
      },
    ),
  );
  history = LocalHistoryEntry(onRemove: session.cancel);
  ModalRoute.of(context)?.addLocalHistoryEntry(history);
  Navigator.of(context, rootNavigator: true).overlay!.insert(entry);
  return completion.future;
}

class _TabBarContextMenu extends StatefulWidget {
  final TabBarContextMenuSession session;
  final List<MainPageRouteData> routes;
  final ValueChanged<TabBarContextMenuResult?> onDismiss;
  final VoidCallback onClosed;

  const _TabBarContextMenu({
    required this.session,
    required this.routes,
    required this.onDismiss,
    required this.onClosed,
  });

  @override
  State<_TabBarContextMenu> createState() => _TabBarContextMenuState();
}

class _TabBarContextMenuState extends State<_TabBarContextMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  bool _closing = false;
  TabBarContextMenuSession get session => widget.session;
  late final Map<String, MainPageRouteData> _routesByPath;

  @override
  void initState() {
    super.initState();
    _routesByPath = {for (final route in widget.routes) route.pagePath: route};
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..forward();
    session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    session.removeListener(_onSessionChanged);
    _animation.dispose();
    super.dispose();
    widget.onClosed();
  }

  void _onSessionChanged() {
    if (session.closeRequested) {
      _dismiss(session.result);
    }
  }

  Future<void> _dismiss(TabBarContextMenuResult? result) async {
    if (_closing) {
      return;
    }
    _closing = true;
    try {
      await _animation.reverse().orCancel;
    } on TickerCanceled {
      return;
    }
    if (mounted) {
      widget.onDismiss(result);
    }
  }

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(
        child: BlockSemantics(
          child: ListenableBuilder(
            listenable: Listenable.merge([_animation, session]),
            builder: (context, _) => _buildMenu(context),
          ),
        ),
      );

  Widget _buildMenu(BuildContext context) {
    final theme = Theme.of(context);
    final progress = Curves.easeOutCubic.transform(_animation.value);
    final menuWidth = (MediaQuery.sizeOf(context).width - 32).clamp(0.0, 280.0);
    final left =
        (session.leftFor(session.heldPath) + session.itemWidth - menuWidth)
            .clamp(16.0, MediaQuery.sizeOf(context).width - menuWidth - 16);
    final background = CupertinoDynamicColor.resolve(
      CupertinoColors.tertiarySystemBackground,
      context,
    );
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: session.barRect.top,
            child: ClipRect(
              key: const ValueKey('tab-bar-blurred-content'),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5 * progress,
                  sigmaY: 5 * progress,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _dismiss(null),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.2 * progress),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fromRect(
            rect: session.barRect,
            child: ColoredBox(color: theme.colorScheme.surface),
          ),
          for (final path in session.paths
              .where((path) => !session.isDragging || path != session.heldPath))
            _tab(context, path, progress),
          if (session.isDragging) _tab(context, session.heldPath, progress),
          Positioned(
            left: left,
            top: session.barRect.top - 96,
            width: menuWidth,
            height: 80,
            child: IgnorePointer(
              ignoring: session.isDragging,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: session.isDragging ? 0 : progress,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ColoredBox(
                    color: background,
                    child: CupertinoContextMenuAction(
                      onPressed: () => _dismiss(
                        TabBarContextMenuResult(
                          paths: session.paths,
                          customize: true,
                        ),
                      ),
                      trailingIcon: CupertinoIcons.gear,
                      child: Text(
                        'Настроить нижнее меню',
                        style: TextStyle(
                          color: CupertinoDynamicColor.resolve(
                            CupertinoColors.label,
                            context,
                          ),
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String path, double progress) {
    final theme = Theme.of(context);
    final route = _routesByPath[path]!;
    final dragging = session.isDragging && session.heldPath == path;
    final selected = path == session.selectedPath;
    final held = session.heldPath == path;
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return AnimatedPositioned(
      key: ValueKey('context-tab-$path'),
      duration: dragging ? Duration.zero : const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      left: dragging ? session.draggedLeft : session.leftFor(path),
      top: session.contentRect.top - (dragging ? 8 : 0),
      width: session.itemWidth,
      height: session.contentRect.height,
      child: TabBarGestureDetector(
        onTap: () => _dismiss(
          TabBarContextMenuResult(
            paths: session.paths,
            destinationPath: path,
          ),
        ),
        onHoldStart: (pointer) => session.begin(path, pointer),
        onHoldMove: session.move,
        onHoldEnd: session.end,
        child: TabBarDragFeedback(
          dragging: dragging,
          backgroundColor: held
              ? TabBarDragFeedback.highlightColor(context, opacity: progress)
              : Colors.transparent,
          child: Center(
            child: TabBarItemContent(
              icon: selected ? route.selectedIcon : route.unselectedIcon,
              label: route.pageTitle,
              color: color,
              labelStyle: CupertinoTheme.of(context)
                  .textTheme
                  .tabLabelTextStyle
                  .copyWith(color: color),
            ),
          ),
        ),
      ),
    );
  }
}
