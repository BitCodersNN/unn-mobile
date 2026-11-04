// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class SubjectDetail extends StatelessWidget {
  final String label;
  final String value;

  const SubjectDetail({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final title = Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
        final content = Text(
          value,
          textAlign: TextAlign.right,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
        return constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(14) > 21
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 4),
                  SizedBox(width: double.infinity, child: content),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: content,
                    ),
                  ),
                ],
              );
      },
    ),
  );
}
