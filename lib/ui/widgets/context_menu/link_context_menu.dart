import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_actions.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_factory.dart';

class LinkContextMenu extends StatefulWidget {
  final String url;
  final String label;
  final VoidCallback onOpen;
  final Widget child;

  const LinkContextMenu({
    required this.url,
    required this.label,
    required this.onOpen,
    required this.child,
    super.key,
  });

  @override
  State<LinkContextMenu> createState() => _LinkContextMenuState();
}

class _LinkContextMenuState extends State<LinkContextMenu> {
  bool _menuOpen = false;

  Future<void> _showMenu() async {
    if (_menuOpen) {
      return;
    }
    final source = context.findRenderObject();
    if (source is! RenderBox || !source.attached) {
      return;
    }
    final navigator = Navigator.of(context, rootNavigator: true);
    final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
    final route = _LinkMenuRoute(
      anchor: overlay.globalToLocal(source.localToGlobal(Offset.zero)) &
          source.size,
      url: widget.url,
      label: widget.label,
      actions: createLinkActions(
        context: context,
        url: widget.url,
        onOpen: widget.onOpen,
      ),
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      dismissLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );
    _menuOpen = true;
    triggerHaptic(HapticIntensity.medium);
    try {
      final action = await navigator.push(route);
      await route.completed;
      if (mounted) {
        action?.call();
      }
    } finally {
      _menuOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onOpen,
        onLongPress: _showMenu,
        child: widget.child,
      );
}

class _LinkMenuRoute extends PopupRoute<VoidCallback> {
  final Rect anchor;
  final String url;
  final String label;
  final List<ContextMenuAction> actions;
  final CapturedThemes themes;
  final String dismissLabel;

  _LinkMenuRoute({
    required this.anchor,
    required this.url,
    required this.label,
    required this.actions,
    required this.themes,
    required this.dismissLabel,
  });

  @override
  bool get barrierDismissible => true;
  @override
  Color? get barrierColor => null;
  @override
  String get barrierLabel => dismissLabel;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 220);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      themes.wrap(
        LayoutBuilder(
          builder: (context, constraints) {
            final media = MediaQuery.of(context);
            final safeArea = EdgeInsets.fromLTRB(
              media.padding.left + 16,
              media.padding.top + 12,
              media.padding.right + 16,
              math.max(media.padding.bottom, media.viewInsets.bottom) + 12,
            ).deflateRect(Offset.zero & constraints.biggest);
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final progress =
                    Curves.easeInOutCubic.transform(animation.value);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(
                            sigmaX: 3 * progress,
                            sigmaY: 3 * progress,
                          ),
                          child: ColoredBox(
                            color:
                                Colors.black.withValues(alpha: 0.1 * progress),
                          ),
                        ),
                      ),
                    ),
                    CustomSingleChildLayout(
                      delegate:
                          _LinkMenuLayout(anchor: anchor, safeArea: safeArea),
                      child: Opacity(
                        opacity: progress,
                        child: Transform.scale(
                          scale: 0.96 + 0.04 * progress,
                          child: child,
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: ContextMenuActions(
                key: const ValueKey('link-menu-card'),
                elevation: 8,
                actions: actions,
                header: _LinkPreview(url: url, label: label),
              ),
            );
          },
        ),
      );
}

class _LinkMenuLayout extends SingleChildLayoutDelegate {
  final Rect anchor;
  final Rect safeArea;

  const _LinkMenuLayout({required this.anchor, required this.safeArea});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: math.min(360, safeArea.width),
        maxWidth: math.min(360, safeArea.width),
        maxHeight: math.max(0.0, safeArea.height),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final below = anchor.bottom + 10;
    final top = below + childSize.height <= safeArea.bottom
        ? below
        : anchor.top - childSize.height - 10;
    return Offset(
      anchor.left.clamp(safeArea.left, safeArea.right - childSize.width),
      top.clamp(safeArea.top, safeArea.bottom - childSize.height),
    );
  }

  @override
  bool shouldRelayout(_LinkMenuLayout oldDelegate) =>
      anchor != oldDelegate.anchor || safeArea != oldDelegate.safeArea;
}

class _LinkPreview extends StatelessWidget {
  final String url;
  final String label;

  const _LinkPreview({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final host = Uri.tryParse(url)?.host ?? '';
    final title = label.trim();
    final heading = title.isNotEmpty && title != url
        ? title
        : host.isNotEmpty
            ? host
            : 'Ссылка';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.link, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  heading,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  url,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
