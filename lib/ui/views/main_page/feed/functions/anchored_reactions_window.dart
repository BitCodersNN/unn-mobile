import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_reaction_picker.dart';

Future<void> showAnchoredReactionChoice(
  BuildContext context,
  ReactionViewModelBase model,
) async {
  final source = context.findRenderObject();
  if (source is! RenderBox || !source.attached) {
    return;
  }
  final navigator = Navigator.of(context, rootNavigator: true);
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  final route = _ReactionChoiceRoute(
    anchor:
        overlay.globalToLocal(source.localToGlobal(Offset.zero)) & source.size,
    selected: model.currentReaction,
    themes: InheritedTheme.capture(from: context, to: navigator.context),
    dismissLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  );
  triggerHaptic(HapticIntensity.medium);
  final reaction = await navigator.push(route);
  await route.completed;
  if (context.mounted && reaction != null) {
    model.toggleReaction(reaction);
  }
}

class _ReactionChoiceRoute extends PopupRoute<ReactionType> {
  final Rect anchor;
  final ReactionType? selected;
  final CapturedThemes themes;
  final String dismissLabel;

  _ReactionChoiceRoute({
    required this.anchor,
    required this.selected,
    required this.themes,
    required this.dismissLabel,
  });

  @override
  bool get barrierDismissible => true;
  @override
  Color get barrierColor => Colors.black.withValues(alpha: 0.06);
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
            return CustomSingleChildLayout(
              delegate:
                  _ReactionChoiceLayout(anchor: anchor, safeArea: safeArea),
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final progress =
                      Curves.easeInOutCubic.transform(animation.value);
                  return Opacity(
                    opacity: progress,
                    child: Transform.scale(
                      scale: 0.96 + 0.04 * progress,
                      child: child,
                    ),
                  );
                },
                child: FeedReactionPicker(
                  key: const ValueKey('reaction-choice-panel'),
                  selected: selected,
                  elevation: 8,
                  onSelected: (reaction) {
                    if (ModalRoute.of(context)?.isCurrent != true) {
                      return;
                    }
                    triggerHaptic(HapticIntensity.selection);
                    Navigator.of(context).pop(reaction);
                  },
                ),
              ),
            );
          },
        ),
      );
}

class _ReactionChoiceLayout extends SingleChildLayoutDelegate {
  final Rect anchor;
  final Rect safeArea;

  const _ReactionChoiceLayout({required this.anchor, required this.safeArea});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: math.min(376, safeArea.width),
        maxWidth: math.min(376, safeArea.width),
        maxHeight: math.max(0.0, safeArea.height),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final above = anchor.top - childSize.height - 8;
    final top = above >= safeArea.top ? above : anchor.bottom + 8;
    return Offset(
      (anchor.center.dx - childSize.width / 2)
          .clamp(safeArea.left, safeArea.right - childSize.width),
      top.clamp(safeArea.top, safeArea.bottom - childSize.height),
    );
  }

  @override
  bool shouldRelayout(_ReactionChoiceLayout oldDelegate) =>
      anchor != oldDelegate.anchor || safeArea != oldDelegate.safeArea;
}
