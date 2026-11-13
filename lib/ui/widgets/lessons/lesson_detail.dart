// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

class LessonDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool expanded;

  const LessonDetail({
    required this.icon,
    required this.text,
    this.expanded = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        theme.unnMobileColors?.ligtherTextColor ??
        theme.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 4),
          child: Icon(icon, color: color, applyTextScaling: true, size: 16),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(color: color),
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            softWrap: expanded,
          ),
        ),
      ],
    );
  }
}
