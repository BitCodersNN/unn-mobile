// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/auth_page/widgets/auth_error_text.dart';

class _FieldMetrics {
  static const double boxHeight = 56;
  static const double errorSlotHeight = 40;
  static const double contentPadding = 20;
  static const double borderRadius = 16;
  static const double borderWidth = 2;
  static const double notchGap = 4;
  static const double shadowOffsetY = 3;
  static const double shadowBlurRadius = 4;
  static const double labelFontSize = 15;
  static const double valueFontSize = 17;
  static const double shadowOpacity = 0.08;
}

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final String? errorText;
  final bool obscured;
  final Iterable<String>? autofillHints;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    required this.controller,
    required this.focusNode,
    required this.labelText,
    required this.obscured,
    required this.autofillHints,
    required this.textInputAction,
    this.errorText,
    this.onSubmitted,
    super.key,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool get _isLabelFloating =>
      widget.focusNode.hasFocus ||
      widget.errorText != null ||
      widget.controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_handleStateChanged);
    widget.focusNode.addListener(_handleStateChanged);
  }

  @override
  void didUpdateWidget(AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleStateChanged);
      widget.controller.addListener(_handleStateChanged);
    }

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleStateChanged);
      widget.focusNode.addListener(_handleStateChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChanged);
    widget.focusNode.removeListener(_handleStateChanged);
    super.dispose();
  }

  void _handleStateChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final labelStyle = TextStyle(
      fontSize: _FieldMetrics.labelFontSize,
      color: theme.hintColor,
    );

    final valueStyle = TextStyle(
      //fontFamily: 'Inter',
      fontSize: _FieldMetrics.valueFontSize,
      color: theme.colorScheme.onSurface,
    );

    final labelWidth = _measureLabelWidth(context, labelStyle);
    final borderColor = _borderColor(theme);
    final cursorColor = widget.errorText != null
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _FieldMetrics.boxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: _isLabelFloating ? 1 : 0),
                  duration: _animationDuration,
                  curve: _animationCurve,
                  builder: (context, labelProgress, child) =>
                      TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: borderColor),
                    duration: _animationDuration,
                    curve: _animationCurve,
                    builder: (context, animatedColor, child) => _decoration(
                      context,
                      labelStyle: labelStyle,
                      labelProgress: labelProgress,
                      labelWidth: labelWidth,
                      borderColor: animatedColor ?? Colors.transparent,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.focusNode.requestFocus,
                ),
              ),
              Positioned.fill(child: _input(valueStyle, cursorColor)),
            ],
          ),
        ),
        AuthErrorText(
          text: widget.errorText,
          reservedHeight: _FieldMetrics.errorSlotHeight,
          contentPadding:
              const EdgeInsets.only(left: _FieldMetrics.contentPadding),
        ),
      ],
    );
  }

  Widget _decoration(
    BuildContext context, {
    required TextStyle labelStyle,
    required double labelProgress,
    required double labelWidth,
    required Color borderColor,
  }) {
    final label = Text(widget.labelText, style: labelStyle);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _FieldBoxPainter(
              labelProgress: labelProgress,
              labelWidth: labelWidth,
              borderColor: borderColor,
              fillColor: Theme.of(context).cardColor,
              shadowColor: Theme.of(context)
                  .shadowColor
                  .withValues(alpha: _FieldMetrics.shadowOpacity),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: _FieldMetrics.contentPadding,
                    ),
                    child: FractionalTranslation(
                      translation: const Offset(0, -0.5),
                      child: Opacity(
                        opacity: labelProgress,
                        child: label,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: _FieldMetrics.contentPadding,
                    ),
                    child: Opacity(
                      opacity: 1 - labelProgress,
                      child: label,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _input(TextStyle valueStyle, Color cursorColor) => Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: double.infinity,
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autocorrect: false,
            enableSuggestions: false,
            obscureText: widget.obscured,
            autofillHints: widget.autofillHints,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            cursorColor: cursorColor,
            style: valueStyle,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: _FieldMetrics.contentPadding,
                right: _FieldMetrics.contentPadding,
              ),
            ),
          ),
        ),
      );

  double _measureLabelWidth(BuildContext context, TextStyle labelStyle) {
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(labelStyle);

    final painter = TextPainter(
      text: TextSpan(text: widget.labelText, style: effectiveStyle),
      textDirection: Directionality.of(context),
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();

    final width = painter.width;
    painter.dispose();
    return width;
  }

  Color _borderColor(ThemeData theme) {
    if (widget.errorText != null) {
      return theme.colorScheme.error;
    }

    if (widget.focusNode.hasFocus) {
      return theme.colorScheme.primary;
    }

    return widget.controller.text.isEmpty
        ? Colors.transparent
        : theme.colorScheme.outlineVariant;
  }

  static const Duration _animationDuration = Duration(milliseconds: 250);
  static const Curve _animationCurve = Curves.easeOutCubic;
}

class _FieldBoxPainter extends CustomPainter {
  final double labelProgress;
  final double labelWidth;
  final Color borderColor;
  final Color fillColor;
  final Color shadowColor;

  const _FieldBoxPainter({
    required this.labelProgress,
    required this.labelWidth,
    required this.borderColor,
    required this.fillColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderWidth = _FieldMetrics.borderWidth;
    final boxRect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(borderWidth / 2),
      Radius.circular(_FieldMetrics.borderRadius - borderWidth / 2),
    );

    if (shadowColor != Colors.transparent) {
      canvas.drawRRect(
        boxRect.shift(const Offset(0, _FieldMetrics.shadowOffsetY)),
        Paint()
          ..color = shadowColor
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            _FieldMetrics.shadowBlurRadius,
          ),
      );
    }

    canvas.drawRRect(boxRect, Paint()..color = fillColor);

    if (borderColor == Colors.transparent) {
      return;
    }

    final borderPath = Path()..addRRect(boxRect);
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderWidth
      ..color = borderColor;

    final gapStart =
        _FieldMetrics.contentPadding - _FieldMetrics.notchGap * labelProgress;
    final gapEnd = _FieldMetrics.contentPadding +
        labelWidth * labelProgress +
        _FieldMetrics.notchGap * labelProgress;

    if (gapEnd > gapStart) {
      final clipPath = Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()
          ..addRect(Rect.fromLTRB(gapStart, -borderWidth, gapEnd, borderWidth)),
      );

      canvas
        ..save()
        ..clipPath(clipPath)
        ..drawPath(borderPath, borderPaint)
        ..restore();
    } else {
      canvas.drawPath(borderPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_FieldBoxPainter oldDelegate) =>
      oldDelegate.labelProgress != labelProgress ||
      oldDelegate.labelWidth != labelWidth ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.shadowColor != shadowColor;
}
