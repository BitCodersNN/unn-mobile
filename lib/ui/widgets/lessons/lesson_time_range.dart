// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

class LessonTimeRange extends StatelessWidget {
  final DateTimeRange range;

  const LessonTimeRange({required this.range, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(range.start.format(DatePattern.hhmm), style: style),
        Text(
          range.end.format(DatePattern.hhmm),
          style: style?.copyWith(
            color:
                theme.unnMobileColors?.ligtherTextColor ??
                theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
