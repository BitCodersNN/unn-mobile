// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_reaction_picker.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_actions.dart';

class FeedItemContextMenu extends StatefulWidget {
  final List<ContextMenuAction> Function(BuildContext) actionsBuilder;
  final ReactionViewModelBase? reactions;
  final BorderRadius borderRadius;
  final GlobalKey? previewKey;
  final Widget child;

  const FeedItemContextMenu({
    required this.actionsBuilder,
    required this.child,
    this.reactions,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.previewKey,
    super.key,
  });

  @override
  State<FeedItemContextMenu> createState() => _FeedItemContextMenuState();
}

class _FeedItemContextMenuState extends State<FeedItemContextMenu> {
  final _previewKey = GlobalKey();
  bool _openingMenu = false;
  bool _menuOpen = false;

  void _setMenuOpen(bool value) {
    if (mounted && _menuOpen != value) {
      setState(() => _menuOpen = value);
    }
  }

  Future<void> _showMenu() async {
    if (_openingMenu) {
      return;
    }
    final source =
        (widget.previewKey ?? _previewKey).currentContext?.findRenderObject();
    if (source is! RenderRepaintBoundary) {
      return;
    }
    _openingMenu = true;
    try {
      await _showFeedItemContextMenu(
        context: context,
        source: source,
        actions: widget.actionsBuilder(context),
        reactions: widget.reactions,
        borderRadius: widget.borderRadius,
        onOpen: () => _setMenuOpen(true),
        onClose: () => _setMenuOpen(false),
      );
    } finally {
      _openingMenu = false;
      _setMenuOpen(false);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
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

Future<void> _showFeedItemContextMenu({
  required BuildContext context,
  required RenderRepaintBoundary source,
  required List<ContextMenuAction> actions,
  required VoidCallback onOpen,
  required VoidCallback onClose,
  ReactionViewModelBase? reactions,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(24)),
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final dismissLabel =
      MaterialLocalizations.of(context).modalBarrierDismissLabel;
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
  try {
    if (!context.mounted) {
      return;
    }
    final route = _FeedItemMenuRoute(
      image: image,
      sourceRect: rect,
      borderRadius: borderRadius,
      actions: actions,
      reactions: reactions,
      themes: themes,
      dismissLabel: dismissLabel,
      onClose: onClose,
    );
    onOpen();
    final action = await navigator.push(route);
    await route.completed;
    if (context.mounted) {
      action?.call();
    }
  } finally {
    image.dispose();
  }
}

class _FeedItemMenuRoute extends PopupRoute<VoidCallback> {
  final ui.Image image;
  final Rect sourceRect;
  final BorderRadius borderRadius;
  final List<ContextMenuAction> actions;
  final ReactionViewModelBase? reactions;
  final CapturedThemes themes;
  final String dismissLabel;
  final VoidCallback onClose;

  _FeedItemMenuRoute({
    required this.image,
    required this.sourceRect,
    required this.borderRadius,
    required this.actions,
    required this.reactions,
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
  ) =>
      themes.wrap(
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
                          color:
                              Colors.black.withValues(alpha: 0.18 * progress),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomMultiChildLayout(
                      delegate: _FeedItemMenuLayout(
                        sourceRect: sourceRect,
                        progress: progress,
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
                          id: _FeedItemMenuSlot.preview,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              key: const ValueKey('feed-menu-preview'),
                              decoration: BoxDecoration(
                                borderRadius: borderRadius,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.18 * progress),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: borderRadius,
                                child: LayoutBuilder(
                                  builder: (context, constraints) =>
                                      OverflowBox(
                                    alignment: Alignment.topCenter,
                                    minWidth: constraints.maxWidth,
                                    maxWidth: constraints.maxWidth,
                                    minHeight: sourceRect.height *
                                        constraints.maxWidth /
                                        sourceRect.width,
                                    maxHeight: sourceRect.height *
                                        constraints.maxWidth /
                                        sourceRect.width,
                                    child: RawImage(
                                      image: image,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (reactions != null)
                          LayoutId(
                            id: _FeedItemMenuSlot.reactions,
                            child: _FeedItemMenuReveal(
                              progress: menuProgress,
                              child: FeedReactionPicker(
                                key: const ValueKey('feed-menu-reactions'),
                                selected: reactions!.currentReaction,
                                onSelected: (reaction) {
                                  if (ModalRoute.of(context)?.isCurrent !=
                                      true) {
                                    return;
                                  }
                                  triggerHaptic(HapticIntensity.selection);
                                  Navigator.of(context).pop<VoidCallback>(
                                    () {
                                      if (reactions!.currentReaction !=
                                          reaction) {
                                        reactions!.toggleReaction(reaction);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        LayoutId(
                          id: _FeedItemMenuSlot.actions,
                          child: _FeedItemMenuReveal(
                            progress: menuProgress,
                            child: ContextMenuActions(
                              key: const ValueKey('feed-menu-actions'),
                              actions: actions,
                              onSelected: (action) {
                                if (ModalRoute.of(context)?.isCurrent ??
                                    false) {
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

enum _FeedItemMenuSlot { preview, reactions, actions }

class _FeedItemMenuLayout extends MultiChildLayoutDelegate {
  final Rect sourceRect;
  final double progress;
  final EdgeInsets padding;

  _FeedItemMenuLayout({
    required this.sourceRect,
    required this.progress,
    required this.padding,
  });

  @override
  void performLayout(Size size) {
    final available = padding.deflateRect(Offset.zero & size);
    final width = math.min(sourceRect.width, available.width);
    final gap = math.min(12.0, available.height * 0.05);
    final reactions = hasChild(_FeedItemMenuSlot.reactions)
        ? layoutChild(
            _FeedItemMenuSlot.reactions,
            BoxConstraints(
              minWidth: width,
              maxWidth: width,
              maxHeight: math.max(0.0, available.height * 0.2),
            ),
          )
        : Size.zero;
    final actions = layoutChild(
      _FeedItemMenuSlot.actions,
      BoxConstraints(
        minWidth: math.min(width, 280),
        maxWidth: math.min(width, 280),
        maxHeight: math.max(0.0, available.height * 0.45),
      ),
    );
    final reactionsSpace = reactions.height > 0 ? reactions.height + gap : 0.0;
    final height = math.min(
      sourceRect.height * width / sourceRect.width,
      math.max(0.0, available.height - reactionsSpace - actions.height - gap),
    );
    final top = sourceRect.top
        .clamp(
          available.top,
          math.max(
            available.top,
            available.bottom - height - reactionsSpace - actions.height - gap,
          ),
        )
        .toDouble();
    final left = sourceRect.left.clamp(
      available.left,
      available.right - width,
    );
    final preview = Rect.lerp(
      sourceRect,
      Rect.fromLTWH(left, top, width, height),
      progress,
    )!;
    layoutChild(_FeedItemMenuSlot.preview, BoxConstraints.tight(preview.size));
    positionChild(_FeedItemMenuSlot.preview, preview.topLeft);
    positionChild(
      _FeedItemMenuSlot.actions,
      Offset(preview.left, preview.bottom + gap + reactionsSpace),
    );
    if (hasChild(_FeedItemMenuSlot.reactions)) {
      positionChild(
        _FeedItemMenuSlot.reactions,
        Offset(preview.left, preview.bottom + gap),
      );
    }
  }

  @override
  bool shouldRelayout(_FeedItemMenuLayout oldDelegate) =>
      sourceRect != oldDelegate.sourceRect ||
      progress != oldDelegate.progress ||
      padding != oldDelegate.padding;
}

class _FeedItemMenuReveal extends StatelessWidget {
  final double progress;
  final Widget child;

  const _FeedItemMenuReveal({required this.progress, required this.child});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - progress)),
          child: child,
        ),
      );
}
