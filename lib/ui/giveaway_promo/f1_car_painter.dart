// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/material.dart';

class F1CarPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double wheelAngle;
  final double speedIntensity;
  final double slipIntensity;

  const F1CarPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.wheelAngle,
    required this.speedIntensity,
    this.slipIntensity = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100.0;
    final sy = size.height / 200.0;

    canvas
      ..save()
      ..scale(sx, sy);

    _drawShadow(canvas);
    if (speedIntensity > 0.01) {
      _drawSpeedLines(canvas);
    }
    if (slipIntensity > 0.01) {
      _drawWheelspinEffects(canvas);
    }
    _drawSuspensionAndFloor(canvas);
    _drawWheel(
      canvas,
      center: const Offset(14, 46),
      width: 15,
      height: 26,
      isRear: false,
    );
    _drawWheel(
      canvas,
      center: const Offset(86, 46),
      width: 15,
      height: 26,
      isRear: false,
    );
    _drawWheel(
      canvas,
      center: const Offset(14, 152),
      width: 18,
      height: 32,
      isRear: true,
    );
    _drawWheel(
      canvas,
      center: const Offset(86, 152),
      width: 18,
      height: 32,
      isRear: true,
    );
    _drawFrontWing(canvas);
    _drawChassis(canvas);
    _drawCockpitAndHalo(canvas);
    _drawRearWing(canvas);
    _drawTowHook(canvas);

    canvas.restore();
  }

  void _drawShadow(Canvas canvas) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(10, 10, 90, 194),
        const Radius.circular(18),
      ),
      shadowPaint,
    );
  }

  void _drawSpeedLines(Canvas canvas) {
    final linePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;
    const xs = [16.0, 34.0, 66.0, 84.0];
    const starts = [184.0, 194.0, 194.0, 184.0];
    const lengths = [22.0, 30.0, 30.0, 22.0];
    for (var i = 0; i < xs.length; i++) {
      final alpha = (0.55 - (i == 0 || i == 3 ? 0.15 : 0.0)) * speedIntensity;
      linePaint.color = accentColor.withValues(alpha: alpha.clamp(0.0, 1.0));
      final startY = starts[i];
      canvas.drawLine(
        Offset(xs[i], startY),
        Offset(xs[i], startY + lengths[i] * speedIntensity),
        linePaint,
      );
    }
  }

  void _drawWheelspinEffects(Canvas canvas) {
    final clampedSlip = slipIntensity.clamp(0.0, 1.0);
    final rubberPaint = Paint()
      ..color = const Color(0xFF1A1C22).withValues(alpha: 0.45 * clampedSlip)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.5;
    final smokePaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    for (final tireX in const [14.0, 86.0]) {
      canvas
        ..drawLine(
          Offset(tireX - 3.5, 166),
          Offset(tireX - 3.5, 196 + 14 * clampedSlip),
          rubberPaint,
        )
        ..drawLine(
          Offset(tireX + 3.5, 166),
          Offset(tireX + 3.5, 198 + 14 * clampedSlip),
          rubberPaint,
        );

      for (var i = 0; i < 4; i++) {
        final phase = (wheelAngle * 0.45 + i * 0.78) % (math.pi * 2);
        final driftX = math.sin(phase) * (3.5 + i * 1.4);
        final puffY = 172.0 + i * 10.5 + math.cos(phase) * 2.0;
        final puffRadius = (6.0 + i * 2.3) * (0.65 + 0.35 * clampedSlip);
        final puffAlpha = (0.62 - i * 0.11) * clampedSlip;
        smokePaint.color = const Color(0xFFE8ECEF)
            .withValues(alpha: puffAlpha.clamp(0.0, 1.0));
        canvas.drawCircle(
          Offset(tireX + driftX, puffY),
          puffRadius,
          smokePaint,
        );
      }
    }
  }

  void _drawSuspensionAndFloor(Canvas canvas) {
    final carbonPaint = Paint()..color = const Color(0xFF181A20);
    final wishbonePaint = Paint()
      ..color = const Color(0xFF2B2F3A)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final floor = Path()
      ..moveTo(32, 62)
      ..lineTo(68, 62)
      ..lineTo(75, 134)
      ..lineTo(66, 174)
      ..lineTo(34, 174)
      ..lineTo(25, 134)
      ..close();

    canvas
      ..drawPath(floor, carbonPaint)
      // Front suspension wishbones
      ..drawLine(const Offset(42, 39), const Offset(18, 44), wishbonePaint)
      ..drawLine(const Offset(41, 52), const Offset(18, 49), wishbonePaint)
      ..drawLine(const Offset(58, 39), const Offset(82, 44), wishbonePaint)
      ..drawLine(const Offset(59, 52), const Offset(82, 49), wishbonePaint)
      // Rear suspension wishbones
      ..drawLine(const Offset(40, 145), const Offset(19, 149), wishbonePaint)
      ..drawLine(const Offset(39, 160), const Offset(19, 156), wishbonePaint)
      ..drawLine(const Offset(60, 145), const Offset(81, 149), wishbonePaint)
      ..drawLine(const Offset(61, 160), const Offset(81, 156), wishbonePaint);
  }

  void _drawWheel(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required bool isRear,
  }) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final tireRRect = RRect.fromRectAndRadius(rect, const Radius.circular(4.2));
    final tirePaint = Paint()..color = const Color(0xFF1A1C22);
    final shoulderPaint = Paint()
      ..color = const Color(0xFF2D313C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas
      ..drawRRect(tireRRect, tirePaint)
      ..drawRRect(tireRRect, shoulderPaint);

    // Animated tread ribs scrolling downward across the tire contact patch.
    final treadPaint = Paint()
      ..color = (isRear && slipIntensity > 0.1)
          ? Color.lerp(
              const Color(0xFF474C5A),
              const Color(0xFFDCE1EA),
              slipIntensity.clamp(0.0, 1.0) * 0.55,
            )!
          : const Color(0xFF3E4350)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas
      ..save()
      ..clipRRect(tireRRect);
    const step = 6.5;
    final offset = (wheelAngle * 4.5) % step;
    for (var y = rect.top - step + offset; y <= rect.bottom + step; y += step) {
      canvas.drawLine(
        Offset(rect.left + 2.2, y),
        Offset(rect.right - 2.2, y),
        treadPaint,
      );
    }
    canvas.restore();

    // Rim stripe along the inner/outer tire shoulder (F1 P-Zero accent).
    final stripePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.78)
      ..strokeWidth = 1.3;
    final stripeX = center.dx < 50 ? rect.right - 1.8 : rect.left + 1.8;
    canvas.drawLine(
      Offset(stripeX, rect.top + 4),
      Offset(stripeX, rect.bottom - 4),
      stripePaint,
    );
  }

  void _drawFrontWing(Canvas canvas) {
    final carbonPaint = Paint()..color = const Color(0xFF1D1F27);
    final mainFlapPaint = Paint()..color = primaryColor;
    final trimPaint = Paint()..color = accentColor;

    final mainPlane = Path()
      ..moveTo(13, 14)
      ..lineTo(50, 7)
      ..lineTo(87, 14)
      ..lineTo(85, 22)
      ..lineTo(50, 17)
      ..lineTo(15, 22)
      ..close();

    canvas
      ..drawPath(mainPlane, carbonPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(16, 14.5, 42, 18.5),
          const Radius.circular(1.4),
        ),
        mainFlapPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(58, 14.5, 84, 18.5),
          const Radius.circular(1.4),
        ),
        mainFlapPaint,
      )
      // Endplates
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(10, 9, 15, 24),
          const Radius.circular(1.8),
        ),
        mainFlapPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(85, 9, 90, 24),
          const Radius.circular(1.8),
        ),
        mainFlapPaint,
      )
      ..drawLine(const Offset(18, 13), const Offset(41, 10), trimPaint)
      ..drawLine(const Offset(82, 13), const Offset(59, 10), trimPaint);
  }

  void _drawChassis(Canvas canvas) {
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.lerp(primaryColor, Colors.black, 0.24)!,
          Color.lerp(primaryColor, Colors.white, 0.14)!,
          primaryColor,
          Color.lerp(primaryColor, Colors.black, 0.24)!,
        ],
        stops: const [0.0, 0.38, 0.58, 1.0],
      ).createShader(const Rect.fromLTRB(26, 4, 74, 176));

    final body = Path()
      ..moveTo(47, 5)
      ..lineTo(53, 5)
      ..lineTo(57, 46)
      ..quadraticBezierTo(62, 62, 74, 72)
      ..quadraticBezierTo(76, 108, 69, 142)
      ..lineTo(59, 174)
      ..lineTo(41, 174)
      ..lineTo(31, 142)
      ..quadraticBezierTo(24, 108, 26, 72)
      ..quadraticBezierTo(38, 62, 43, 46)
      ..close();
    canvas.drawPath(body, bodyPaint);

    // Sidepod undercut shadows and radiator intakes.
    final intakePaint = Paint()..color = const Color(0xFF14161C);
    final sidepodShade = Paint()
      ..color = Color.lerp(primaryColor, Colors.black, 0.34)!;
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(28, 70, 38, 76),
          const Radius.circular(2.0),
        ),
        intakePaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(62, 70, 72, 76),
          const Radius.circular(2.0),
        ),
        intakePaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(28, 79, 36.5, 134),
          const Radius.circular(4.0),
        ),
        sidepodShade,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(63.5, 79, 72, 134),
          const Radius.circular(4.0),
        ),
        sidepodShade,
      );

    // Racing livery stripes along nose & engine cover.
    final stripePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final leftStripe = Path()
      ..moveTo(47.5, 14)
      ..lineTo(44, 58)
      ..lineTo(38.5, 86)
      ..lineTo(42.5, 162);
    final rightStripe = Path()
      ..moveTo(52.5, 14)
      ..lineTo(56, 58)
      ..lineTo(61.5, 86)
      ..lineTo(57.5, 162);
    canvas
      ..drawPath(leftStripe, stripePaint)
      ..drawPath(rightStripe, stripePaint);
  }

  void _drawCockpitAndHalo(Canvas canvas) {
    final cockpitPaint = Paint()..color = const Color(0xFF15171E);
    final helmetPaint = Paint()..color = Colors.white;
    final visorPaint = Paint()..color = const Color(0xFF1B2738);
    final airboxPaint = Paint()..color = const Color(0xFF14161C);

    canvas
      ..drawOval(const Rect.fromLTRB(41.5, 78, 58.5, 108), cockpitPaint)
      ..drawCircle(const Offset(50, 92), 6.2, helmetPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(45.8, 86.2, 54.2, 89.8),
          const Radius.circular(1.6),
        ),
        visorPaint,
      )
      // Overhead airbox intake behind driver
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(47.2, 106, 52.8, 117),
          const Radius.circular(1.8),
        ),
        airboxPaint,
      );

    // Halo titanium protection bar
    final haloPaint = Paint()
      ..color = const Color(0xFFDFE4EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final haloRing = Path()
      ..moveTo(41, 95)
      ..quadraticBezierTo(41, 75, 50, 74)
      ..quadraticBezierTo(59, 75, 59, 95);
    canvas
      ..drawPath(haloRing, haloPaint)
      ..drawLine(const Offset(50, 74), const Offset(50, 84), haloPaint);
  }

  void _drawRearWing(Canvas canvas) {
    final carbonPaint = Paint()..color = const Color(0xFF1D1F27);
    final flapPaint = Paint()..color = primaryColor;
    final drsAccentPaint = Paint()..color = accentColor;
    final rainLightPaint = Paint()..color = const Color(0xFFFF3B30);

    canvas
      // Endplates
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(20, 173, 25, 190),
          const Radius.circular(1.8),
        ),
        carbonPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(75, 173, 80, 190),
          const Radius.circular(1.8),
        ),
        carbonPaint,
      )
      // Main plane
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(23, 175, 77, 184),
          const Radius.circular(2.0),
        ),
        flapPaint,
      )
      // DRS upper flap
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(24, 184, 76, 189),
          const Radius.circular(1.5),
        ),
        carbonPaint,
      )
      ..drawLine(
        const Offset(27, 186.5),
        const Offset(73, 186.5),
        drsAccentPaint..strokeWidth = 1.5,
      )
      // Rear diffuser & rain light
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(38, 188, 62, 193),
          const Radius.circular(1.5),
        ),
        carbonPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(48.2, 189.2, 51.8, 192.2),
          const Radius.circular(0.8),
        ),
        rainLightPaint,
      );
  }

  void _drawTowHook(Canvas canvas) {
    final hookPaint = Paint()
      ..color = const Color(0xFFCFD6E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(const Offset(50, 194), 3.2, hookPaint);
  }

  @override
  bool shouldRepaint(covariant F1CarPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.wheelAngle != wheelAngle ||
      oldDelegate.speedIntensity != speedIntensity ||
      oldDelegate.slipIntensity != slipIntensity;
}

class F1TowCablePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double opacity;

  const F1TowCablePainter({
    required this.start,
    required this.end,
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) {
      return;
    }
    final alpha = opacity.clamp(0.0, 1.0);
    final delta = end - start;
    final length = delta.distance;
    if (length <= 0.5) {
      return;
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.28 * alpha)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final strapPaint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final chevronPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55 * alpha)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final unit = delta / length;
    final perp = Offset(-unit.dy, unit.dx);

    canvas
      ..drawLine(start, end, glowPaint)
      ..drawLine(start, end, strapPaint);

    // Braided tension chevrons along the taut tow strap.
    for (var d = 10.0; d < length - 8.0; d += 10.0) {
      final center = start + unit * d;
      final tip = center - unit * 3.0;
      canvas
        ..drawLine(tip, center + perp * 2.4, chevronPaint)
        ..drawLine(tip, center - perp * 2.4, chevronPaint);
    }

    final ringStroke = Paint()
      ..color = color.withValues(alpha: alpha)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final ringFill = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * alpha)
      ..style = PaintingStyle.fill;

    for (final anchor in [start, end]) {
      canvas
        ..drawCircle(anchor, 4.2, ringFill)
        ..drawCircle(anchor, 4.2, ringStroke);
    }
  }

  @override
  bool shouldRepaint(covariant F1TowCablePainter oldDelegate) =>
      oldDelegate.start != start ||
      oldDelegate.end != end ||
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity;
}
