// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_actions.dart';

typedef PreviewContextMenuAccessoryBuilder = Widget Function(
  BuildContext context,
  void Function(VoidCallback action) dismiss,
);

class PreviewContextMenu extends StatefulWidget {
  final List<ContextMenuAction> Function(BuildContext) actionsBuilder;
  final PreviewContextMenuAccessoryBuilder? topAccessoryBuilder;
  final BorderRadius borderRadius;
  final GlobalKey? previewKey;
  final double minActionsWidth;
  final bool enabled;
  final Widget child;

  const PreviewContextMenu({
    required this.actionsBuilder,
    required this.child,
    this.topAccessoryBuilder,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.previewKey,
    this.minActionsWidth = 220,
    this.enabled = true,
    super.key,
  });

  @override
  State<PreviewContextMenu> createState() => _PreviewContextMenuState();
}

class _PreviewContextMenuState extends State<PreviewContextMenu> {
  final _previewKey = GlobalKey();
  bool _openingMenu = false;
  bool _menuOpen = false;

  void _setMenuOpen(bool value) {
    if (mounted && _menuOpen != value) {
      setState(() => _menuOpen = value);
    }
  }

  Future<void> _showMenu() async {
    if (!widget.enabled || _openingMenu) {
      return;
    }
    final source = (widget.previewKey ?? _previewKey).currentContext
        ?.findRenderObject();
    if (source is! RenderRepaintBoundary) {
      return;
    }
    _openingMenu = true;
    try {
      await _showPreviewContextMenu(
        context: context,
        source: source,
        actions: widget.actionsBuilder(context),
        topAccessoryBuilder: widget.topAccessoryBuilder,
        borderRadius: widget.borderRadius,
        minActionsWidth: widget.minActionsWidth,
        onOpen: () => _setMenuOpen(true),
        onClose: () => _setMenuOpen(false),
      );
    } finally {
      _openingMenu = false;
      _setMenuOpen(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return GestureDetector(
      onLongPress: _showMenu,
      child: Opacity(
        opacity: _menuOpen ? 0 : 1,
        child: RepaintBoundary(
          key: widget.previewKey ?? _previewKey,
          child: widget.child,
        ),
      ),
    );
  }
}

Future<void> _showPreviewContextMenu({
  required BuildContext context,
  required RenderRepaintBoundary source,
  required List<ContextMenuAction> actions,
  required VoidCallback onOpen,
  required VoidCallback onClose,
  PreviewContextMenuAccessoryBuilder? topAccessoryBuilder,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(24)),
  double minActionsWidth = 220,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final dismissLabel = MaterialLocalizations.of(context)
      .modalBarrierDismissLabel;
  final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  triggerHaptic(HapticIntensity.medium);
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) {
    return;
  }
  if (!source.attached || !overlay.attached) {
    return;
  }
  final rect =
      overlay.globalToLocal(source.localToGlobal(Offset.zero)) & source.size;
  final pixelRatio = math.min(
    devicePixelRatio.clamp(1.0, 2.0),
    math.sqrt(4000000 / (source.size.width * source.size.height)),
  );
  final image = await source.toImage(pixelRatio: pixelRatio);
  final VoidCallback? action;
  try {
    action = context.mounted
        ? await _pushPreviewMenuRoute(
            navigator: navigator,
            image: image,
            sourceRect: rect,
            borderRadius: borderRadius,
            actions: actions,
            topAccessoryBuilder: topAccessoryBuilder,
            minActionsWidth: minActionsWidth,
            themes: themes,
            dismissLabel: dismissLabel,
            onOpen: onOpen,
            onClose: onClose,
          )
        : null;
  } finally {
    image.dispose();
  }
  if (context.mounted) {
    action?.call();
  }
}

Future<VoidCallback?> _pushPreviewMenuRoute({
  required NavigatorState navigator,
  required ui.Image image,
  required Rect sourceRect,
  required BorderRadius borderRadius,
  required List<ContextMenuAction> actions,
  required PreviewContextMenuAccessoryBuilder? topAccessoryBuilder,
  required double minActionsWidth,
  required CapturedThemes themes,
  required String dismissLabel,
  required VoidCallback onOpen,
  required VoidCallback onClose,
}) async {
  final route = _PreviewMenuRoute(
    image: image,
    sourceRect: sourceRect,
    borderRadius: borderRadius,
    actions: actions,
    topAccessoryBuilder: topAccessoryBuilder,
    minActionsWidth: minActionsWidth,
    themes: themes,
    dismissLabel: dismissLabel,
    onClose: onClose,
  );
  onOpen();
  final action = await navigator.push(route);
  await route.completed;
  return action;
}

class _PreviewMenuRoute extends PopupRoute<VoidCallback> {
  final ui.Image image;
  final Rect sourceRect;
  final BorderRadius borderRadius;
  final List<ContextMenuAction> actions;
  final PreviewContextMenuAccessoryBuilder? topAccessoryBuilder;
  final double minActionsWidth;
  final CapturedThemes themes;
  final String dismissLabel;
  final VoidCallback onClose;

  _PreviewMenuRoute({
    required this.image,
    required this.sourceRect,
    required this.borderRadius,
    required this.actions,
    required this.topAccessoryBuilder,
    required this.minActionsWidth,
    required this.themes,
    required this.dismissLabel,
    required this.onClose,
  });

  @override
  Animation<double> createAnimation() =>
      super.createAnimation()..addStatusListener(_onAnimationStatusChanged);

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      onClose();
    }
  }

  @override
  void dispose() {
    animation?.removeStatusListener(_onAnimationStatusChanged);
    super.dispose();
  }

  @override
  bool get barrierDismissible => true;
  @override
  Color? get barrierColor => null;
  @override
  String get barrierLabel => dismissLabel;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 340);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 240);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => themes.wrap(
    AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = Curves.easeInOutCubic.transform(animation.value);
        final menuProgress = const Interval(
          0.12,
          1,
          curve: Curves.easeInOutCubic,
        ).transform(animation.value);
        final insets = MediaQuery.of(context);
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 5 * progress,
                      sigmaY: 5 * progress,
                    ),
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.18 * progress),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomMultiChildLayout(
                  delegate: _PreviewMenuLayout(
                    sourceRect: sourceRect,
                    progress: progress,
                    minActionsWidth: minActionsWidth,
                    padding: EdgeInsets.fromLTRB(
                      insets.padding.left + 16,
                      insets.padding.top + 12,
                      insets.padding.right + 16,
                      math.max(
                            insets.padding.bottom,
                            insets.viewInsets.bottom,
                          ) +
                          12,
                    ),
                  ),
                  children: [
                    LayoutId(
                      id: _PreviewMenuSlot.preview,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          key: const ValueKey('feed-menu-preview'),
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.18 * progress,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: borderRadius,
                            child: LayoutBuilder(
                              builder: (context, constraints) => OverflowBox(
                                alignment: Alignment.topCenter,
                                minWidth: constraints.maxWidth,
                                maxWidth: constraints.maxWidth,
                                minHeight: sourceRect.width > 0
                                    ? sourceRect.height *
                                          constraints.maxWidth /
                                          sourceRect.width
                                    : 0.0,
                                maxHeight: sourceRect.width > 0
                                    ? sourceRect.height *
                                          constraints.maxWidth /
                                          sourceRect.width
                                    : 0.0,
                                child: RawImage(image: image, fit: BoxFit.fill),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (topAccessoryBuilder != null)
                      LayoutId(
                        id: _PreviewMenuSlot.accessory,
                        child: _PreviewMenuReveal(
                          progress: menuProgress,
                          child: topAccessoryBuilder!(context, (action) {
                            if (ModalRoute.of(context)?.isCurrent ?? false) {
                              Navigator.of(context).pop<VoidCallback>(action);
                            }
                          }),
                        ),
                      ),
                    LayoutId(
                      id: _PreviewMenuSlot.actions,
                      child: _PreviewMenuReveal(
                        progress: menuProgress,
                        child: ContextMenuActions(
                          key: const ValueKey('feed-menu-actions'),
                          actions: actions,
                          onSelected: (action) {
                            if (ModalRoute.of(context)?.isCurrent ?? false) {
                              triggerHaptic(HapticIntensity.light);
                              Navigator.of(context).pop(action.onTap);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

enum _PreviewMenuSlot { preview, accessory, actions }

class _PreviewMenuLayout extends MultiChildLayoutDelegate {
  final Rect sourceRect;
  final double progress;
  final double minActionsWidth;
  final EdgeInsets padding;

  _PreviewMenuLayout({
    required this.sourceRect,
    required this.progress,
    required this.minActionsWidth,
    required this.padding,
  });

  @override
  void performLayout(Size size) {
    final available = padding.deflateRect(Offset.zero & size);
    final width = math.min(sourceRect.width, available.width);
    final gap = math.min(12.0, available.height * 0.05);
    final accessory = hasChild(_PreviewMenuSlot.accessory)
        ? layoutChild(
            _PreviewMenuSlot.accessory,
            BoxConstraints(
              minWidth: width,
              maxWidth: width,
              maxHeight: math.max(0.0, available.height * 0.2),
            ),
          )
        : Size.zero;
    final actionsWidth = math.min(
      math.max(width, minActionsWidth),
      math.min(280.0, available.width),
    );
    final actions = layoutChild(
      _PreviewMenuSlot.actions,
      BoxConstraints(
        minWidth: actionsWidth,
        maxWidth: actionsWidth,
        maxHeight: math.max(0.0, available.height * 0.45),
      ),
    );
    final accessorySpace = accessory.height > 0 ? accessory.height + gap : 0.0;
    final targetAspectHeight = sourceRect.width > 0
        ? sourceRect.height * width / sourceRect.width
        : 0.0;
    final height = math.min(
      targetAspectHeight,
      math.max(0.0, available.height - accessorySpace - actions.height - gap),
    );
    final top = sourceRect.top
        .clamp(
          available.top,
          math.max(
            available.top,
            available.bottom - height - accessorySpace - actions.height - gap,
          ),
        )
        .toDouble();
    final left = sourceRect.left
        .clamp(
          available.left,
          math.max(available.left, available.right - width),
        )
        .toDouble();
    final preview = Rect.lerp(
      sourceRect,
      Rect.fromLTWH(left, top, width, height),
      progress,
    )!;
    layoutChild(_PreviewMenuSlot.preview, BoxConstraints.tight(preview.size));
    positionChild(_PreviewMenuSlot.preview, preview.topLeft);
    final actionsLeft = preview.left
        .clamp(
          available.left,
          math.max(available.left, available.right - actions.width),
        )
        .toDouble();
    positionChild(
      _PreviewMenuSlot.actions,
      Offset(actionsLeft, preview.bottom + gap + accessorySpace),
    );
    if (hasChild(_PreviewMenuSlot.accessory)) {
      positionChild(
        _PreviewMenuSlot.accessory,
        Offset(preview.left, preview.bottom + gap),
      );
    }
  }

  @override
  bool shouldRelayout(_PreviewMenuLayout oldDelegate) =>
      sourceRect != oldDelegate.sourceRect ||
      progress != oldDelegate.progress ||
      minActionsWidth != oldDelegate.minActionsWidth ||
      padding != oldDelegate.padding;
}

class _PreviewMenuReveal extends StatelessWidget {
  final double progress;
  final Widget child;

  const _PreviewMenuReveal({required this.progress, required this.child});

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: progress,
    child: Transform.translate(
      offset: Offset(0, 8 * (1 - progress)),
      child: child,
    ),
  );
}
