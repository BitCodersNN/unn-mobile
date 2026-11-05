// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';

class ScheduleLessonProgress extends StatefulWidget {
  final DateTimeRange range;
  final Color color;
  final Widget Function({required bool hasTimeBadge}) builder;
  final Widget endTime;

  const ScheduleLessonProgress({
    required this.range,
    required this.color,
    required this.builder,
    required this.endTime,
    super.key,
  });

  @override
  State<ScheduleLessonProgress> createState() => _ScheduleLessonProgressState();
}

class _ScheduleLessonProgressState extends State<ScheduleLessonProgress>
    with WidgetsBindingObserver {
  static const _upcomingNotice = Duration(minutes: 10);

  Timer? _timer;
  DateTime _now = DateTime.now();

  bool get _isActive =>
      !widget.range.end.isBefore(widget.range.start) &&
      !_now.isBefore(widget.range.start) &&
      _now.isBefore(widget.range.end);

  bool get _isUpcoming =>
      widget.range.end.isAfter(widget.range.start) &&
      _now.isBefore(widget.range.start) &&
      !_now.isBefore(widget.range.start.subtract(_upcomingNotice));

  bool get _hasTimeBadge => _isActive || _isUpcoming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleUpdate();
  }

  @override
  void didUpdateWidget(covariant ScheduleLessonProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.range != widget.range) {
      _now = DateTime.now();
      _scheduleUpdate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed) {
      _update();
    }
  }

  void _update() {
    setState(() => _now = DateTime.now());
    _scheduleUpdate();
  }

  void _scheduleUpdate() {
    _timer?.cancel();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      return;
    }
    if (_hasTimeBadge) {
      final boundary = _isActive ? widget.range.end : widget.range.start;
      final remaining = boundary.difference(_now);
      const interval = Duration(seconds: 1);
      _timer = Timer(remaining < interval ? remaining : interval, _update);
    } else if (_now.isBefore(widget.range.start) &&
        widget.range.end.isAfter(widget.range.start)) {
      final noticeStart = widget.range.start.subtract(_upcomingNotice);
      _timer = Timer(noticeStart.difference(_now), _update);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transitionDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    final boundary = _isActive ? widget.range.end : widget.range.start;
    final remaining = boundary.difference(_now);
    final minutes = (remaining.inMilliseconds / Duration.millisecondsPerMinute)
        .ceil();
    final progress = _isActive
        ? (_now.difference(widget.range.start).inMilliseconds /
                  widget.range.duration.inMilliseconds)
              .clamp(0.0, 1.0)
        : 1.0;
    final label = _isActive
        ? 'Осталось $minutes мин'
        : 'До начала $minutes мин';

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 4,
          child: Semantics(
            label: _isActive ? 'Ход занятия' : null,
            value: _isActive ? label : null,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: AnimatedContainer(
                duration: transitionDuration,
                color: _isActive
                    ? widget.color.withValues(alpha: 0.18)
                    : widget.color,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: transitionDuration,
                    curve: Curves.easeInOut,
                    builder: (context, value, child) => FractionallySizedBox(
                      heightFactor: value,
                      widthFactor: 1,
                      child: child,
                    ),
                    child: _isActive
                        ? _ProgressLineFill(color: widget.color)
                        : ColoredBox(color: widget.color),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.builder(hasTimeBadge: _hasTimeBadge),
              AnimatedSwitcher(
                duration: transitionDuration,
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                ),
                child: _hasTimeBadge
                    ? Padding(
                        key: const ValueKey('lessonTimeBadge'),
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _LiveDot(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: AnimatedSize(
                                        duration: transitionDuration,
                                        alignment: Alignment.centerLeft,
                                        curve: Curves.easeInOutCubic,
                                        child: AnimatedSwitcher(
                                          duration: transitionDuration,
                                          child: Text(
                                            label,
                                            key: ValueKey(label),
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            widget.endTime,
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressLineFill extends StatefulWidget {
  final Color color;

  const _ProgressLineFill({required this.color});

  @override
  State<_ProgressLineFill> createState() => _ProgressLineFillState();
}

class _ProgressLineFillState extends State<_ProgressLineFill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseTone = HSLColor.fromColor(widget.color);
    final waveColor = baseTone
        .withLightness((baseTone.lightness + 0.08).clamp(0.0, 1.0))
        .toColor();

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = Curves.easeInOut.transform(_controller.value) * 6;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0, offset - 3),
                end: Alignment(0, offset - 1),
                colors: [widget.color, waveColor, widget.color],
              ),
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  final Color color;

  const _LiveDot({required this.color});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.35,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller,
    child: DecoratedBox(
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      child: const SizedBox.square(dimension: 5),
    ),
  );
}
