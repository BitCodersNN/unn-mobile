// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
}

class Shimmer extends StatefulWidget {
  static ShimmerState? of(BuildContext context) =>
      context.findAncestorStateOfType<ShimmerState>();

  const Shimmer({super.key, this.linearGradient, this.child});

  final LinearGradient? linearGradient;
  final Widget? child;

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  Gradient get gradient {
    final theme = Theme.of(context);
    final extraColors = theme.unnMobileColors;
    final base =
        extraColors?.shimmerBaseColor ?? theme.colorScheme.surfaceContainer;
    final highlight =
        extraColors?.shimmerHighlightColor ??
        theme.colorScheme.surfaceContainerHighest;
    final gradient =
        widget.linearGradient ??
        LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.1, 0.3, 0.4],
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
        );
    return LinearGradient(
      colors: gradient.colors,
      stops: gradient.stops,
      begin: gradient.begin,
      end: gradient.end,
      tileMode: gradient.tileMode,
      transform: _SlidingGradientTransform(
        slidePercent: _shimmerController.value,
      ),
    );
  }

  late AnimationController _shimmerController;

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size => (context.findRenderObject()! as RenderBox).size;

  Listenable get shimmerChanges => _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject()! as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  @override
  Widget build(BuildContext context) => widget.child ?? const SizedBox();

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
}
