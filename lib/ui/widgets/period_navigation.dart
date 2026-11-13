// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class PeriodNavigation extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PeriodNavigation({
    required this.child,
    this.onPrevious,
    this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: onPrevious,
        icon: const Icon(Icons.arrow_left),
        iconSize: 32,
      ),
      Expanded(child: child),
      IconButton(
        onPressed: onNext,
        icon: const Icon(Icons.arrow_right),
        iconSize: 32,
      ),
    ],
  );
}
