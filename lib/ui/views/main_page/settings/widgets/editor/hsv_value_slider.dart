// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/editor/interactive_color_track.dart';

class HsvValueSlider extends StatelessWidget {
  static const double _height = 38;
  static const double _barVerticalInset = 6;

  final HSVColor hsv;
  final VoidCallback onInteractionStart;
  final ValueChanged<double> onChanged;

  const HsvValueSlider({
    required this.hsv,
    required this.onInteractionStart,
    required this.onChanged,
    super.key,
  });

  void _updateFromOffset(Offset localPosition, double width) {
    final dx = localPosition.dx.clamp(0.0, width);
    onChanged(1.0 - (dx / width));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fullValueColor = HSVColor.fromAHSV(
      1,
      hsv.hue,
      hsv.saturation,
      1,
    ).toColor();
    final pointerColor = colors.onSurface;

    return InteractiveColorTrack(
      height: _height,
      onInteractionStart: onInteractionStart,
      onPositionChanged: _updateFromOffset,
      builder: (context, width) {
        final pointerX = (1.0 - hsv.value).clamp(0.0, 1.0) * width;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: _barVerticalInset,
              bottom: _barVerticalInset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  gradient: LinearGradient(
                    colors: [fullValueColor, Colors.black],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ValuePointersPainter(
                    x: pointerX,
                    color: pointerColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ValuePointersPainter extends CustomPainter {
  final double x;
  final Color color;

  const _ValuePointersPainter({required this.x, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const halfBase = 5.0;
    const pointerHeight = 6.0;
    if (size.width < halfBase * 2) {
      return;
    }
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final clampedX = x.clamp(halfBase, size.width - halfBase);

    final topTriangle = Path()
      ..moveTo(clampedX - halfBase, 0)
      ..lineTo(clampedX + halfBase, 0)
      ..lineTo(clampedX, pointerHeight)
      ..close();

    final bottomTriangle = Path()
      ..moveTo(clampedX - halfBase, size.height)
      ..lineTo(clampedX + halfBase, size.height)
      ..lineTo(clampedX, size.height - pointerHeight)
      ..close();

    canvas
      ..drawPath(topTriangle, fillPaint)
      ..drawPath(bottomTriangle, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _ValuePointersPainter oldDelegate) =>
      oldDelegate.x != x || oldDelegate.color != color;
}
