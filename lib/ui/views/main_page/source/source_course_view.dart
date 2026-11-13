// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_course_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/source/source_item_view.dart';
import 'package:unn_mobile/ui/widgets/count_badge.dart';
import 'package:unn_mobile/ui/widgets/expandable_card.dart';

class SourceCourseView extends StatelessWidget {
  final SourceCourseViewModel model;
  final bool even;

  const SourceCourseView({required this.model, this.even = false, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpandableCard(
      key: PageStorageKey(model.discipline),
      title: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: even
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              model.discipline,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      trailing: CountBadge(count: model.items.length),
      child: model.items.isEmpty
          ? Text(
              'Материалы пока не добавлены',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                for (final item in model.items) SourceItemView(model: item),
              ],
            ),
    );
  }
}
