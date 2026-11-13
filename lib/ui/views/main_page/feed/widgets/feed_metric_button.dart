// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_action_style.dart';

class FeedMetricButton extends StatelessWidget {
  final IconData? icon;
  final int? count;
  final String label;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const FeedMetricButton({
    required this.count,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Semantics(
        label: count == null ? label : '$label: $count',
        button: onTap != null,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: feedActionBorderRadius,
          child: Container(
            padding: EdgeInsets.fromLTRB(12, 6, icon == null ? 12 : 8, 6),
            decoration: BoxDecoration(
              color: backgroundColor ?? colors.surfaceContainerLow,
              borderRadius: feedActionBorderRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: colors.onSecondaryContainer, size: 20),
                  const SizedBox(width: 6),
                ],
                Text(
                  count?.toString() ?? '—',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
