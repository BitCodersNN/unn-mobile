// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Material(
            color: theme.colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, child) in children.indexed) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.45,
                      ),
                    ),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
