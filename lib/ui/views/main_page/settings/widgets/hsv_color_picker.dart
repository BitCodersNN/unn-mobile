// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';

class HsvColorPicker extends StatefulWidget {
  final HSVColor hsv;
  final String hex;
  final Color currentColor;
  final bool canReset;
  final void Function(double hue, double saturation) onHueSaturationChanged;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<String> onHexChanged;
  final VoidCallback onReset;

  const HsvColorPicker({
    required this.hsv,
    required this.hex,
    required this.currentColor,
    required this.canReset,
    required this.onHueSaturationChanged,
    required this.onValueChanged,
    required this.onHexChanged,
    required this.onReset,
    super.key,
  });

  @override
  State<HsvColorPicker> createState() => _HsvColorPickerState();
}

class _HsvColorPickerState extends State<HsvColorPicker> {
  late final TextEditingController _hexController;
  late final FocusNode _hexFocusNode;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(text: widget.hex);
    _hexFocusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant HsvColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hex != oldWidget.hex &&
        (!_hexFocusNode.hasFocus ||
            _normalizeHex(_hexController.text) != widget.hex.toUpperCase())) {
      _syncControllerText(widget.hex);
    }
  }

  @override
  void dispose() {
    _hexFocusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _hexController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_hexFocusNode.hasFocus && _hexController.text != widget.hex) {
      _syncControllerText(widget.hex);
    }
  }

  void _syncControllerText(String value) {
    _hexController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _normalizeHex(String input) {
    final cleaned = input.trim().replaceFirst('#', '').toUpperCase();
    return '#$cleaned';
  }

  void _handleHexInput(String value) {
    final match = RegularExpressions.hexColor6RegExp.firstMatch(value.trim());
    if (match != null) {
      widget.onHexChanged('#${match.group(1)!.toUpperCase()}');
    }
  }

  void _handleHexSubmitted(String value) {
    widget.onHexChanged(value);
    _hexFocusNode.unfocus();
    if (_hexController.text != widget.hex) {
      _syncControllerText(widget.hex);
    }
  }

  void _unfocusIfNeeded() {
    if (_hexFocusNode.hasFocus) {
      _hexFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDarkSurface =
        ThemeData.estimateBrightnessForColor(colors.surface) == Brightness.dark;
    final outerRingColor = isDarkSurface
        ? Colors.white.withValues(alpha: 0.38)
        : Colors.black.withValues(alpha: 0.28);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: outerRingColor, width: 1.5),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.currentColor,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _hexController,
                  focusNode: _hexFocusNode,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(7),
                    FilteringTextInputFormatter.allow(
                      RegularExpressions.allowedHexCharsRegExp,
                    ),
                  ],
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    hintText: '#000000',
                  ),
                  onChanged: _handleHexInput,
                  onSubmitted: _handleHexSubmitted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 42,
              height: 42,
              child: IconButton.filledTonal(
                onPressed: widget.canReset
                    ? () {
                        _unfocusIfNeeded();
                        widget.onReset();
                      }
                    : null,
                tooltip: 'Сбросить элемент',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.restart_alt_rounded, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _HueSaturationSpectrum(
          hsv: widget.hsv,
          onInteractionStart: _unfocusIfNeeded,
          onChanged: widget.onHueSaturationChanged,
        ),
        const SizedBox(height: 14),
        _ValueSlider(
          hsv: widget.hsv,
          onInteractionStart: _unfocusIfNeeded,
          onChanged: widget.onValueChanged,
        ),
      ],
    );
  }
}

class _InteractiveColorTrack extends StatelessWidget {
  final double height;
  final VoidCallback onInteractionStart;
  final void Function(Offset localPosition, double width) onPositionChanged;
  final Widget Function(BuildContext context, double width) builder;

  const _InteractiveColorTrack({
    required this.height,
    required this.onInteractionStart,
    required this.onPositionChanged,
    required this.builder,
  });

  void _handleDown(Offset localPosition, double width) {
    onInteractionStart();
    _handleUpdate(localPosition, width);
  }

  void _handleUpdate(Offset localPosition, double width) {
    if (width > 0) {
      onPositionChanged(localPosition, width);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _handleDown(details.localPosition, width),
        onPanDown: (details) => _handleDown(details.localPosition, width),
        onPanUpdate: (details) => _handleUpdate(details.localPosition, width),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: builder(context, width),
        ),
      );
    },
  );
}

class _HueSaturationSpectrum extends StatelessWidget {
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

  const _HueSaturationSpectrum({
    required this.hsv,
    required this.onInteractionStart,
    required this.onChanged,
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
    final colors = Theme.of(context).colorScheme;
    final fullValueColor = HSVColor.fromAHSV(
      1,
      hsv.hue,
      hsv.saturation,
      1,
    ).toColor();

    return _InteractiveColorTrack(
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
                        color: Colors.black.withValues(alpha: 0.35),
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

class _ValueSlider extends StatelessWidget {
  static const double _height = 38;
  static const double _barVerticalInset = 6;

  final HSVColor hsv;
  final VoidCallback onInteractionStart;
  final ValueChanged<double> onChanged;

  const _ValueSlider({
    required this.hsv,
    required this.onInteractionStart,
    required this.onChanged,
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

    return _InteractiveColorTrack(
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
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    const halfBase = 5.0;
    const pointerHeight = 6.0;
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
