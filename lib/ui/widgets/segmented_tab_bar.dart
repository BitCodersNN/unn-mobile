// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/count_badge.dart';

class SegmentedTabItem {
  final String label;
  final int? count;
  final String? countSemanticLabel;
  final CountBadgeTone countTone;

  const SegmentedTabItem({
    required this.label,
    this.count,
    this.countSemanticLabel,
    this.countTone = CountBadgeTone.accent,
  });
}

class SegmentedTabBar extends StatelessWidget {
  static const _horizontalPadding = 10.0;
  static const _countGap = 12.0;

  final List<SegmentedTabItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final ValueListenable<double?>? position;
  final Color? borderColor;

  const SegmentedTabBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.position,
    this.borderColor,
    super.key,
  }) : assert(items.length > 0),
       assert(selectedIndex >= 0 && selectedIndex < items.length);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final labelStyle = theme.textTheme.labelLarge!.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: colors.onSurface,
      height: 1.2,
    );
    final counts = {
      for (final (index, item) in items.indexed)
        if ((item.count ?? 0) > 0) index: item.count!,
    };
    final scaler = MediaQuery.textScalerOf(context);
    final countSizes = {
      for (final entry in counts.entries)
        entry.key: CountBadge.measure(
          context,
          entry.value,
          maximum: 99,
          compact: true,
        ),
    };
    final countHeight = countSizes.values.fold(
      0.0,
      (height, size) => math.max(height, size.height),
    );
    final height = math.max(
      math.max(36.0, scaler.scale(13) * 1.2 + 14),
      countHeight + 8,
    );
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor ?? colors.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widths = [
              for (final (index, item) in items.indexed)
                _textWidth(context, item.label, labelStyle) +
                    (countSizes.containsKey(index)
                        ? countSizes[index]!.width + _countGap * 3
                        : _horizontalPadding * 2),
            ];
            final minimumWidth = widths.fold(0.0, (sum, width) => sum + width);
            final width = constraints.hasBoundedWidth
                ? math.max(constraints.maxWidth, minimumWidth)
                : minimumWidth;
            final extra = (width - minimumWidth) / widths.length;
            final sizes = [for (final size in widths) size + extra];
            final starts = <double>[];
            double offset = 0;
            for (final size in sizes) {
              starts.add(offset);
              offset += size;
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    _indicator(
                      context,
                      selectedIndex: selectedIndex,
                      starts: starts,
                      widths: sizes,
                      duration: duration,
                    ),
                    Row(
                      children: [
                        for (final (index, item) in items.indexed)
                          SizedBox(
                            width: widths[index] + extra,
                            height: height,
                            child: Semantics(
                              button: true,
                              selected: selectedIndex == index,
                              enabled: onSelected != null,
                              label: item.label,
                              value: counts.containsKey(index)
                                  ? item.countSemanticLabel ?? '${item.count}'
                                  : null,
                              excludeSemantics: true,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  onTap: onSelected == null
                                      ? null
                                      : () => onSelected!(index),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: counts.containsKey(index)
                                          ? 0
                                          : _horizontalPadding,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          counts.containsKey(index)
                                          ? MainAxisAlignment.spaceEvenly
                                          : MainAxisAlignment.center,
                                      children: [
                                        Text(item.label, style: labelStyle),
                                        if (counts.containsKey(index)) ...[
                                          CountBadge(
                                            count: counts[index]!,
                                            maximum: 99,
                                            compact: true,
                                            tone: item.countTone,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _indicator(
    BuildContext context, {
    required int selectedIndex,
    required List<double> starts,
    required List<double> widths,
    required Duration duration,
  }) {
    Widget buildIndicator(double? page) {
      final target = (page ?? selectedIndex.toDouble()).clamp(
        0.0,
        items.length - 1.0,
      );
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: target, end: target),
        duration: page == null ? duration : Duration.zero,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          final page = value.clamp(0.0, items.length - 1.0);
          final left = page.floor();
          final right = page.ceil();
          final fraction = page - left;
          return PositionedDirectional(
            start: starts[left] + (starts[right] - starts[left]) * fraction,
            top: 0,
            bottom: 0,
            width: widths[left] + (widths[right] - widths[left]) * fraction,
            child: child!,
          );
        },
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      );
    }

    final pagePosition = position;
    return pagePosition == null
        ? buildIndicator(null)
        : ValueListenableBuilder<double?>(
            valueListenable: pagePosition,
            builder: (context, page, _) => buildIndicator(page),
          );
  }

  double _textWidth(BuildContext context, String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}
