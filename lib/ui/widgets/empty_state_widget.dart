// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String caption;
  final VoidCallback? onIconTap;

  const EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.caption,
    this.onIconTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circle = Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40,
        color: theme.colorScheme.primary,
      ),
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            onIconTap == null
                ? circle
                : InkWell(
                    onTap: onIconTap,
                    borderRadius: BorderRadius.circular(48),
                    child: circle,
                  ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
