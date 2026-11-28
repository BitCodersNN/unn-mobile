// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/material.dart';

class HorizontalPeekList extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double height;
  final double horizontalPadding;
  final double spacing;
  final double minItemWidth;
  final double maxItemWidth;
  final double peekFraction;
  final double fadeWidth;
  final Color? fadeColor;
  final int? initialSelectedIndex;

  const HorizontalPeekList({
    required this.itemCount,
    required this.itemBuilder,
    required this.height,
    this.horizontalPadding = 16,
    this.spacing = 12,
    this.minItemWidth = 112,
    this.maxItemWidth = 142,
    this.peekFraction = 0.32,
    this.fadeWidth = 24,
    this.fadeColor,
    this.initialSelectedIndex,
    super.key,
  }) : assert(itemCount >= 0),
       assert(minItemWidth > 0 && maxItemWidth >= minItemWidth),
       assert(peekFraction > 0 && peekFraction < 1);

  /// Вычисляет ширину карточки так, чтобы либо поместились все элементы,
  /// либо край следующей карточки гарантированно выглядывал на [peekFraction].
  static double resolveItemWidth({
    required double availableWidth,
    required int itemCount,
    required double horizontalPadding,
    required double spacing,
    required double minItemWidth,
    required double maxItemWidth,
    required double peekFraction,
  }) {
    if (itemCount <= 0 || availableWidth <= 0) {
      return maxItemWidth;
    }
    final innerWidth = availableWidth - horizontalPadding * 2;
    final fitAllWidth = (innerWidth - spacing * (itemCount - 1)) / itemCount;
    if (fitAllWidth >= minItemWidth) {
      return fitAllWidth.clamp(minItemWidth, maxItemWidth);
    }

    for (var fullCards = itemCount - 1; fullCards >= 1; fullCards--) {
      final candidate =
          (availableWidth - horizontalPadding - spacing * fullCards) /
          (fullCards + peekFraction);
      if (candidate >= minItemWidth) {
        return math.min(candidate, maxItemWidth);
      }
    }
    return minItemWidth;
  }

  @override
  State<HorizontalPeekList> createState() => _HorizontalPeekListState();
}

class _HorizontalPeekListState extends State<HorizontalPeekList> {
  late final ScrollController _controller = ScrollController()
    ..addListener(_onScroll);
  bool _canScrollStart = false;
  bool _canScrollEnd = false;
  bool _didRevealInitial = false;
  bool _syncScheduled = false;
  double? _lastWidth;
  double? _lastItemWidth;

  @override
  void didUpdateWidget(covariant HorizontalPeekList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _scheduleSync();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.hasClients) {
      _updateEdgeFade(_controller.position);
    }
  }

  void _scheduleSync() {
    if (_syncScheduled) {
      return;
    }
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted || !_controller.hasClients) {
        return;
      }
      final position = _controller.position;
      final itemWidth = _lastItemWidth;
      if (itemWidth != null) {
        _maybeRevealInitial(position, itemWidth);
      }
      _updateEdgeFade(position);
    });
  }

  void _updateEdgeFade(ScrollMetrics metrics) {
    const epsilon = 1.0;
    final nextStart = metrics.pixels > metrics.minScrollExtent + epsilon;
    final nextEnd = metrics.pixels < metrics.maxScrollExtent - epsilon;
    if (nextStart != _canScrollStart || nextEnd != _canScrollEnd) {
      setState(() {
        _canScrollStart = nextStart;
        _canScrollEnd = nextEnd;
      });
    }
  }

  void _maybeRevealInitial(ScrollMetrics metrics, double itemWidth) {
    if (_didRevealInitial) {
      return;
    }
    _didRevealInitial = true;
    final index = widget.initialSelectedIndex;
    if (index == null || index <= 0 || index >= widget.itemCount) {
      return;
    }
    final itemEnd =
        widget.horizontalPadding +
        index * (itemWidth + widget.spacing) +
        itemWidth +
        widget.horizontalPadding;
    if (itemEnd <= metrics.viewportDimension) {
      return;
    }
    final target = (itemEnd - metrics.viewportDimension).clamp(
      metrics.minScrollExtent,
      metrics.maxScrollExtent,
    );
    if (target > metrics.pixels) {
      _controller.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fadeColor =
        widget.fadeColor ??
        Material.maybeOf(context)?.color ??
        Theme.of(context).colorScheme.surface;

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = HorizontalPeekList.resolveItemWidth(
            availableWidth: constraints.maxWidth,
            itemCount: widget.itemCount,
            horizontalPadding: widget.horizontalPadding,
            spacing: widget.spacing,
            minItemWidth: widget.minItemWidth,
            maxItemWidth: widget.maxItemWidth,
            peekFraction: widget.peekFraction,
          );
          if (_lastWidth != constraints.maxWidth ||
              _lastItemWidth != itemWidth) {
            _lastWidth = constraints.maxWidth;
            _lastItemWidth = itemWidth;
            _scheduleSync();
          }

          return Stack(
            children: [
              ListView.separated(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                ),
                itemCount: widget.itemCount,
                separatorBuilder: (_, _) => SizedBox(width: widget.spacing),
                itemBuilder: (context, index) => SizedBox(
                  width: itemWidth,
                  child: widget.itemBuilder(context, index),
                ),
              ),
              _HorizontalEdgeFade(
                visible: _canScrollStart,
                alignment: Alignment.centerLeft,
                color: fadeColor,
                width: widget.fadeWidth,
              ),
              _HorizontalEdgeFade(
                visible: _canScrollEnd,
                alignment: Alignment.centerRight,
                color: fadeColor,
                width: widget.fadeWidth,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HorizontalEdgeFade extends StatelessWidget {
  final bool visible;
  final Alignment alignment;
  final Color color;
  final double width;

  const _HorizontalEdgeFade({
    required this.visible,
    required this.alignment,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isStart = alignment == Alignment.centerLeft;
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: SizedBox(
            width: width,
            height: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: isStart ? Alignment.centerLeft : Alignment.centerRight,
                  end: isStart ? Alignment.centerRight : Alignment.centerLeft,
                  colors: [color, color.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
