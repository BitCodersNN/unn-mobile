// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/count_badge.dart';

class DayHeader extends StatelessWidget {
  final String dayOfWeek;
  final String formattedDate;
  final int lessonsCount;
  final bool isToday;

  const DayHeader({
    required this.dayOfWeek,
    required this.formattedDate,
    required this.lessonsCount,
    required this.isToday,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          dayOfWeek.toUpperCase(),
          style: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formattedDate,
          style: theme.textTheme.titleMedium!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(width: 10),
        CountBadge(count: lessonsCount),
        const SizedBox(width: 12),
        if (isToday) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Сегодня',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        Expanded(
          child: Container(
            height: 1.0,
            color: theme.dividerColor.withValues(alpha: 0.25),
          ),
        ),
      ],
    );
  }
}
