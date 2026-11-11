// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class ThemeAwareTickerMode extends StatefulWidget {
  static const _settleDuration = Duration(seconds: 2);

  final bool enabled;
  final Widget child;

  const ThemeAwareTickerMode({
    required this.enabled,
    required this.child,
    super.key,
  });

  @override
  State<ThemeAwareTickerMode> createState() => _ThemeAwareTickerModeState();
}

class _ThemeAwareTickerModeState extends State<ThemeAwareTickerMode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _themeTransition = AnimationController(
    vsync: this,
    duration: ThemeAwareTickerMode._settleDuration + kThemeChangeDuration,
  )..addStatusListener(_onTransitionStatus);
  ThemeData? _theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    if (_theme != null && _theme != theme) {
      _themeTransition.forward(from: 0);
    }
    _theme = theme;
  }

  void _onTransitionStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => TickerMode(
    enabled: widget.enabled || _themeTransition.isAnimating,
    child: widget.child,
  );

  @override
  void dispose() {
    _themeTransition.dispose();
    super.dispose();
  }
}
