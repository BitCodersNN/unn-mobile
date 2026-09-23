// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/query_chip.dart';

class DayHeader extends StatelessWidget {
  final String dayOfWeek;
  final String formattedDate;
  final int pairsCount;
  final bool isToday;
  final String? queryLabel;
  final VoidCallback? onClearQuery;
  final bool showQueryChip;

  const DayHeader({
    required this.dayOfWeek,
    required this.formattedDate,
    required this.pairsCount,
    required this.isToday,
    this.queryLabel,
    this.onClearQuery,
    this.showQueryChip = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: Row(
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
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$pairsCount',
              style: theme.textTheme.labelMedium!.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1.0,
              color: theme.dividerColor.withValues(alpha: 0.25),
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
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
          ] else if (showQueryChip &&
              queryLabel != null &&
              onClearQuery != null) ...[
            const SizedBox(width: 12),
            QueryChip(
              label: queryLabel!,
              onClear: onClearQuery!,
            ),
          ],
        ],
      ),
    );
  }
}
