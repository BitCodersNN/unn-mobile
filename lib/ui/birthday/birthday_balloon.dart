// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

void paintBirthdayBalloon(
  Canvas canvas, {
  required double width,
  required double height,
  required Color color,
}) {
  final string = Path()
    ..moveTo(0, height * 0.48)
    ..cubicTo(
      -width * 0.16,
      height * 0.8,
      width * 0.18,
      height,
      0,
      height * 1.3,
    );
  canvas.drawPath(
    string,
    Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2,
  );
  final body = Rect.fromCenter(
    center: Offset.zero,
    width: width * 1.16,
    height: height,
  );
  canvas
    ..drawOval(
      body.shift(const Offset(1, 3)),
      Paint()
        ..color = const Color(0xFF263C43).withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    )
    ..drawOval(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          radius: 1.1,
          colors: [Color.lerp(color, Colors.white, 0.4)!, color],
        ).createShader(body),
    );
  final knot = Path()
    ..moveTo(0, height * 0.47)
    ..lineTo(-width * 0.055, height * 0.55)
    ..quadraticBezierTo(0, height * 0.58, width * 0.055, height * 0.55)
    ..close();
  canvas
    ..drawPath(knot, Paint()..color = color)
    ..drawOval(
      Rect.fromCenter(
        center: Offset(-width * 0.24, -height * 0.24),
        width: width * 0.12,
        height: height * 0.23,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
}
