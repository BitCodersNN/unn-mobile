// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/theme_aware_ticker_mode.dart';

class ThemeAwareIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;

  const ThemeAwareIndexedStack({
    required this.index,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: index,
    children: [
      for (final (childIndex, child) in children.indexed)
        Offstage(
          key: child.key,
          offstage: childIndex != index,
          child: ThemeAwareTickerMode(
            enabled: childIndex == index,
            child: child,
          ),
        ),
    ],
  );
}
