// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class TabBarLabelLayout extends StatelessWidget {
  static const labelHeight = 14.0;
  static const horizontalLabelPadding = 4.0;

  final List<String> labels;
  final double itemHorizontalPadding;
  final Widget child;

  const TabBarLabelLayout({
    required this.labels,
    required this.child,
    this.itemHorizontalPadding = 0,
    super.key,
  });

  static ({TextStyle style, TextScaler scaler})? maybeOf(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<_TabBarLabelTheme>();
    return theme == null ? null : (style: theme.style, scaler: theme.scaler);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scaler = MediaQuery.textScalerOf(context);
      final baseStyle = CupertinoTheme.of(context).textTheme.tabLabelTextStyle;
      final style = MediaQuery.boldTextOf(context)
          ? baseStyle.copyWith(fontWeight: FontWeight.bold)
          : baseStyle;
      final width = labels.isEmpty
          ? constraints.maxWidth
          : constraints.maxWidth / labels.length -
                2 * (horizontalLabelPadding + itemHorizontalPadding);
      return _TabBarLabelTheme(
        style: style.copyWith(
          fontSize: _fitFontSize(context, style, scaler, math.max(0, width)),
        ),
        scaler: scaler,
        child: child,
      );
    },
  );

  double _fitFontSize(
    BuildContext context,
    TextStyle style,
    TextScaler scaler,
    double width,
  ) {
    final maximum =
        style.fontSize ??
        const CupertinoTextThemeData().tabLabelTextStyle.fontSize!;
    final painters = [
      for (final label in labels)
        TextPainter(
          text: TextSpan(text: label),
          textDirection: Directionality.of(context),
          textScaler: scaler,
          locale: Localizations.maybeLocaleOf(context),
          maxLines: 1,
        ),
    ];
    bool fits(double size) {
      for (final painter in painters) {
        painter.text = TextSpan(
          text: painter.text!.toPlainText(),
          style: style.copyWith(fontSize: size),
        );
        painter.layout();
        if (painter.width > width || painter.height > labelHeight) {
          return false;
        }
      }
      return true;
    }

    try {
      if (fits(maximum)) {
        return maximum;
      }
      double lower = 0;
      double upper = maximum;
      for (int iteration = 0; iteration < 12; iteration++) {
        final middle = (lower + upper) / 2;
        if (fits(middle)) {
          lower = middle;
        } else {
          upper = middle;
        }
      }
      return lower;
    } finally {
      for (final painter in painters) {
        painter.dispose();
      }
    }
  }
}

class _TabBarLabelTheme extends InheritedTheme {
  final TextStyle style;
  final TextScaler scaler;

  const _TabBarLabelTheme({
    required this.style,
    required this.scaler,
    required super.child,
  });

  @override
  bool updateShouldNotify(_TabBarLabelTheme oldWidget) =>
      style != oldWidget.style || scaler != oldWidget.scaler;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      _TabBarLabelTheme(style: style, scaler: scaler, child: child);
}
