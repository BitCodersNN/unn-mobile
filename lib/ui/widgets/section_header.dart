// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/count_badge.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    required this.title,
    this.count,
    this.padding = const EdgeInsets.fromLTRB(16, 22, 16, 4),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * (count == null ? 0.85 : 0.65),
              ),
              child: Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: colors.outlineVariant)),
            if (count != null) ...[
              const SizedBox(width: 12),
              CountBadge(count: count!),
            ],
          ],
        ),
      ),
    );
  }
}
