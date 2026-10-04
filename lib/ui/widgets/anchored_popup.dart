import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';

enum AnchoredPopupPlacement { above, below }

enum AnchoredPopupAlignment { start, center }

Future<T?> showAnchoredPopup<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  required double width,
  AnchoredPopupPlacement placement = AnchoredPopupPlacement.above,
  AnchoredPopupAlignment alignment = AnchoredPopupAlignment.center,
  double gap = 8,
  double blurSigma = 0,
  double barrierOpacity = 0.06,
}) async {
  final source = context.findRenderObject();
  if (source is! RenderBox || !source.attached) {
    return null;
  }
  final navigator = Navigator.of(context, rootNavigator: true);
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  final route = _AnchoredPopupRoute<T>(
    anchor:
        overlay.globalToLocal(source.localToGlobal(Offset.zero)) & source.size,
    builder: builder,
    width: width,
    gap: gap,
    placement: placement,
    alignment: alignment,
    blurSigma: blurSigma,
    barrierOpacity: barrierOpacity,
    themes: InheritedTheme.capture(from: context, to: navigator.context),
    dismissLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  );
  triggerHaptic(HapticIntensity.medium);
  final result = await navigator.push(route);
  await route.completed;
  return context.mounted ? result : null;
}

void dismissAnchoredPopup<T>(BuildContext context, T result) {
  if (ModalRoute.of(context)?.isCurrent ?? false) {
    Navigator.of(context).pop(result);
  }
}

class _AnchoredPopupRoute<T> extends PopupRoute<T> {
  final Rect anchor;
  final WidgetBuilder builder;
  final double width;
  final double gap;
  final AnchoredPopupPlacement placement;
  final AnchoredPopupAlignment alignment;
  final double blurSigma;
  final double barrierOpacity;
  final CapturedThemes themes;
  final String dismissLabel;

  _AnchoredPopupRoute({
    required this.anchor,
    required this.builder,
    required this.width,
    required this.gap,
    required this.placement,
    required this.alignment,
    required this.blurSigma,
    required this.barrierOpacity,
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
                final backdrop = ColoredBox(
                  color:
                      Colors.black.withValues(alpha: barrierOpacity * progress),
                );
                return Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: blurSigma > 0
                            ? BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: blurSigma * progress,
                                  sigmaY: blurSigma * progress,
                                ),
                                child: backdrop,
                              )
                            : backdrop,
                      ),
                    ),
                    CustomSingleChildLayout(
                      delegate: _AnchoredPopupLayout(
                        anchor: anchor,
                        safeArea: safeArea,
                        width: width,
                        gap: gap,
                        placement: placement,
                        alignment: alignment,
                      ),
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
              child: Builder(builder: builder),
            );
          },
        ),
      );
}

class _AnchoredPopupLayout extends SingleChildLayoutDelegate {
  final Rect anchor;
  final Rect safeArea;
  final double width;
  final double gap;
  final AnchoredPopupPlacement placement;
  final AnchoredPopupAlignment alignment;

  const _AnchoredPopupLayout({
    required this.anchor,
    required this.safeArea,
    required this.width,
    required this.gap,
    required this.placement,
    required this.alignment,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: math.min(width, math.max(0, safeArea.width)),
        maxWidth: math.min(width, math.max(0, safeArea.width)),
        maxHeight: math.max(0, safeArea.height),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final above = anchor.top - childSize.height - gap;
    final below = anchor.bottom + gap;
    final top = switch (placement) {
      AnchoredPopupPlacement.above => above >= safeArea.top ? above : below,
      AnchoredPopupPlacement.below =>
        below + childSize.height <= safeArea.bottom ? below : above,
    };
    final left = switch (alignment) {
      AnchoredPopupAlignment.start => anchor.left,
      AnchoredPopupAlignment.center => anchor.center.dx - childSize.width / 2,
    };
    return Offset(
      left.clamp(
        safeArea.left,
        math.max(safeArea.left, safeArea.right - childSize.width),
      ),
      top.clamp(
        safeArea.top,
        math.max(safeArea.top, safeArea.bottom - childSize.height),
      ),
    );
  }

  @override
  bool shouldRelayout(_AnchoredPopupLayout oldDelegate) =>
      anchor != oldDelegate.anchor ||
      safeArea != oldDelegate.safeArea ||
      width != oldDelegate.width ||
      gap != oldDelegate.gap ||
      placement != oldDelegate.placement ||
      alignment != oldDelegate.alignment;
}
