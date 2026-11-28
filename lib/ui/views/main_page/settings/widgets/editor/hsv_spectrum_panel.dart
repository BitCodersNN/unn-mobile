// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/editor/interactive_color_track.dart';

class HsvSpectrumPanel extends StatelessWidget {
  static const double _height = 168;
  static const double _cursorSize = 26;
  static const _hueStops = [
    Color(0xFFFF0000),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
  ];

  final HSVColor hsv;
  final VoidCallback onInteractionStart;
  final void Function(double hue, double saturation) onChanged;

  const HsvSpectrumPanel({
    required this.hsv,
    required this.onInteractionStart,
    required this.onChanged,
    super.key,
  });

  void _updateFromOffset(Offset localPosition, double width) {
    final dx = localPosition.dx.clamp(0.0, width);
    final dy = localPosition.dy.clamp(0.0, _height);
    final hue = (dx / width) * 360.0;
    final saturation = 1.0 - (dy / _height);
    onChanged(hue, saturation);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fullValueColor = HSVColor.fromAHSV(
      1,
      hsv.hue,
      hsv.saturation,
      1,
    ).toColor();

    return InteractiveColorTrack(
      height: _height,
      onInteractionStart: onInteractionStart,
      onPositionChanged: _updateFromOffset,
      builder: (context, width) {
        final cursorX = (hsv.hue / 360.0).clamp(0.0, 1.0) * width;
        final cursorY = (1.0 - hsv.saturation).clamp(0.0, 1.0) * _height;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _hueStops),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: cursorX - _cursorSize / 2,
              top: cursorY - _cursorSize / 2,
              child: IgnorePointer(
                child: Container(
                  width: _cursorSize,
                  height: _cursorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fullValueColor,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.35),
                        blurRadius: 6,
                        spreadRadius: 0.5,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
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
