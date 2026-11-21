// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class SettingsIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const SettingsIcon({required this.icon, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? Theme.of(context).colorScheme.primary;
    return ExcludeSemantics(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: foreground, size: 21),
      ),
    );
  }
}
