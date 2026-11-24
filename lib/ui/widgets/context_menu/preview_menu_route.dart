// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_actions.dart';
import 'package:unn_mobile/ui/widgets/context_menu/preview_menu_layout.dart';

typedef PreviewContextMenuAccessoryBuilder = Widget Function(
  BuildContext context,
  void Function(VoidCallback action) dismiss,
);

class PreviewMenuRoute extends PopupRoute<VoidCallback> {
  final ui.Image image;
  final Rect sourceRect;
  final BorderRadius borderRadius;
  final double minActionsWidth;
  final List<ContextMenuAction> actions;
  final PreviewContextMenuAccessoryBuilder? topAccessoryBuilder;
  final CapturedThemes themes;
  final String dismissLabel;
  final VoidCallback onClose;

  PreviewMenuRoute({
    required this.image,
    required this.sourceRect,
    required this.borderRadius,
    required this.minActionsWidth,
    required this.actions,
    required this.topAccessoryBuilder,
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
        final theme = Theme.of(context);
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
                      color: theme.colorScheme.scrim.withValues(
                        alpha: 0.18 * progress,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomMultiChildLayout(
                  delegate: PreviewMenuLayout(
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
                      id: PreviewMenuSlot.preview,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          key: const ValueKey('preview-menu-preview'),
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withValues(
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
                        id: PreviewMenuSlot.accessory,
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
                      id: PreviewMenuSlot.actions,
                      child: _PreviewMenuReveal(
                        progress: menuProgress,
                        child: ContextMenuActions(
                          key: const ValueKey('preview-menu-actions'),
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
