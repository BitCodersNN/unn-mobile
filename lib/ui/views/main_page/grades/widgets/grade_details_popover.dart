import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';

typedef GradeDetailsCallback = void Function(
  BuildContext context,
  Object key,
  Widget details,
);

typedef GradeDetailsDismiss = Future<void> Function();

class GradeDetailsPopover extends StatefulWidget {
  final Widget Function(
    BuildContext,
    Object?,
    GradeDetailsCallback,
    GradeDetailsDismiss,
  ) builder;

  final bool openBelow;

  const GradeDetailsPopover({
    required this.builder,
    this.openBelow = false,
    super.key,
  });

  @override
  State<GradeDetailsPopover> createState() => _GradeDetailsPopoverState();
}

class _GradeDetailsPopoverState extends State<GradeDetailsPopover>
    with SingleTickerProviderStateMixin {
  final _portal = OverlayPortalController();
  final _tapRegionGroup = Object();
  late final AnimationController _animation;
  Object? _selected;
  Widget? _details;
  Rect? _anchor;
  ScrollPosition? _scrollPosition;
  Rect? _viewportBounds;
  int _openVersion = 0;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    )..addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _portal.hide();
      setState(() => _selected = null);
    }
  }

  Future<void> _closeDetails() async {
    if (!_portal.isShowing || _animation.status == AnimationStatus.reverse) {
      return;
    }
    try {
      await _animation.reverse().orCancel;
    } on TickerCanceled {
      return;
    }
  }

  Future<void> _showDetails(
    BuildContext context,
    Object key,
    Widget details,
  ) async {
    final version = ++_openVersion;
    if (_selected == key && _animation.status != AnimationStatus.reverse) {
      await _closeDetails();
      return;
    }
    final overlay = Navigator.of(context, rootNavigator: true)
        .overlay!
        .context
        .findRenderObject()! as RenderBox;
    final scrollable = Scrollable.maybeOf(context);
    final viewport = scrollable?.context.findRenderObject();
    final source = context.findRenderObject()! as RenderBox;
    final initialAnchor =
        overlay.globalToLocal(source.localToGlobal(Offset.zero)) & source.size;
    final viewportBounds = viewport is RenderBox
        ? overlay.globalToLocal(viewport.localToGlobal(Offset.zero)) &
            viewport.size
        : null;
    if (widget.openBelow &&
        scrollable != null &&
        viewportBounds != null &&
        viewportBounds.bottom - initialAnchor.bottom < 120) {
      await _closeDetails();
      if (!mounted || !context.mounted || version != _openVersion) {
        return;
      }
      await Scrollable.ensureVisible(
        context,
        alignment: 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
      );
      if (!mounted ||
          !context.mounted ||
          version != _openVersion ||
          !source.attached) {
        return;
      }
    }
    final anchor =
        overlay.globalToLocal(source.localToGlobal(Offset.zero)) & source.size;
    _scrollPosition?.removeListener(_closeDetails);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_closeDetails);
    triggerHaptic(HapticIntensity.selection);
    setState(() {
      _selected = key;
      _details = details;
      _anchor = anchor;
      _viewportBounds = viewportBounds;
    });
    _portal.show();
    _animation.forward();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_closeDetails);
    _animation
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  Widget _buildDetails(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final screenArea = EdgeInsets.fromLTRB(
          media.padding.left + 16,
          media.padding.top + 12,
          media.padding.right + 16,
          math.max(media.padding.bottom, media.viewInsets.bottom) + 12,
        ).deflateRect(Offset.zero & constraints.biggest);
        final safeArea = _viewportBounds == null
            ? screenArea
            : screenArea.intersect(_viewportBounds!.deflate(8));
        return CustomSingleChildLayout(
          delegate: _GradeDetailsLayout(
            anchor: _anchor!,
            safeArea: safeArea,
            openBelow: widget.openBelow,
          ),
          child: TapRegion(
            groupId: _tapRegionGroup,
            child: FadeTransition(
              opacity:
                  _animation.drive(CurveTween(curve: Curves.easeInOutCubic)),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _details,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
        overlayLocation: OverlayChildLocation.rootOverlay,
        controller: _portal,
        overlayChildBuilder: _buildDetails,
        child: TapRegion(
          groupId: _tapRegionGroup,
          onTapOutside: (_) => _closeDetails(),
          child:
              widget.builder(context, _selected, _showDetails, _closeDetails),
        ),
      );
}

class _GradeDetailsLayout extends SingleChildLayoutDelegate {
  final Rect anchor;
  final Rect safeArea;
  final bool openBelow;

  const _GradeDetailsLayout({
    required this.anchor,
    required this.safeArea,
    required this.openBelow,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: math.min(280, math.max(0, safeArea.width)),
        maxHeight: math.max(
          0,
          openBelow
              ? safeArea.bottom - anchor.bottom - 4
              : math.max(
                  anchor.top - safeArea.top - 4,
                  safeArea.bottom - anchor.bottom - 4,
                ),
        ),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final below = anchor.bottom + 4;
    final top = openBelow || below + childSize.height <= safeArea.bottom
        ? below
        : anchor.top - childSize.height - 4;
    return Offset(
      (anchor.center.dx - childSize.width / 2).clamp(
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
  bool shouldRelayout(_GradeDetailsLayout oldDelegate) =>
      anchor != oldDelegate.anchor ||
      safeArea != oldDelegate.safeArea ||
      openBelow != oldDelegate.openBelow;
}
