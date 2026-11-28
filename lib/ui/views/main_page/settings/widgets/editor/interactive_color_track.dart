// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class InteractiveColorTrack extends StatelessWidget {
  final double height;
  final VoidCallback onInteractionStart;
  final void Function(Offset localPosition, double width) onPositionChanged;
  final Widget Function(BuildContext context, double width) builder;

  const InteractiveColorTrack({
    required this.height,
    required this.onInteractionStart,
    required this.onPositionChanged,
    required this.builder,
    super.key,
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
