// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/material.dart';

class CountBadge extends StatelessWidget {
  final int count;
  final int? maximum;
  final bool compact;

  const CountBadge({
    required this.count,
    this.maximum,
    this.compact = false,
    super.key,
  });

  static String _label(int count, int? maximum) =>
      maximum != null && count > maximum ? '$maximum+' : '$count';

  static TextStyle _style(BuildContext context, {required bool compact}) {
    final theme = Theme.of(context);
    return theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      fontSize: compact ? 11 : null,
    );
  }

  static Size measure(
    BuildContext context,
    int count, {
    int? maximum,
    bool compact = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: _label(count, maximum),
        style: _style(context, compact: compact),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: 1,
    )..layout();
    final size = Size(
      math.max(compact ? 20 : 24, painter.width + (compact ? 8 : 12)),
      math.max(compact ? 20 : 24, painter.height + (compact ? 6 : 8)),
    );
    painter.dispose();
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final size = measure(context, count, maximum: maximum, compact: compact);
    return Container(
      width: size.width,
      height: size.height,
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      ),
      alignment: Alignment.center,
      child: Text(
        _label(count, maximum),
        maxLines: 1,
        style: _style(context, compact: compact),
      ),
    );
  }
}
