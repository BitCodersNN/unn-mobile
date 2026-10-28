// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/birthday/birthday_balloon.dart';

class BirthdayBalloons extends CustomPainter {
  final Animation<double> animation;

  BirthdayBalloons(this.animation) : super(repaint: animation);

  static const _colors = [
    Color(0xFF71CFC0),
    Color(0xFFF2B8A2),
    Color(0xFFB9ACE0),
    Color(0xFFF0D18A),
    Color(0xFF94BEE4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    if (progress == 0 || progress == 1) {
      return;
    }
    const columns = 6;
    final width = (size.width / (columns - 1)).clamp(54.0, 125.0);
    final height = width * 1.24;
    for (int row = 0; row < 5; row++) {
      for (int column = 0; column < columns; column++) {
        final index = row * columns + column;
        final delay = row * 0.045 + (column.isEven ? 0 : 0.018);
        final flight = ((progress - delay) / 0.74).clamp(0.0, 1.0);
        final eased = Curves.easeInOutCubic.transform(flight);
        final x = column * size.width / (columns - 1) +
            math.sin(flight * math.pi * 2 + index) * width * 0.13;
        final y = size.height + height - eased * (size.height + height * 3.2);
        canvas
          ..save()
          ..translate(x, y)
          ..rotate(math.sin(flight * math.pi * 2 + index) * 0.08);
        paintBirthdayBalloon(
          canvas,
          width: width,
          height: height,
          color: _colors[index % _colors.length],
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(BirthdayBalloons oldDelegate) =>
      oldDelegate.animation != animation;
}
