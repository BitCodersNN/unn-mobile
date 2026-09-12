// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';

class ScheduleSearchSuggestionItemView extends StatelessWidget {
  final ScheduleSearchSuggestionItem model;
  final IdType searchType;
  final String query;
  final void Function() onSelected;

  const ScheduleSearchSuggestionItemView({
    required this.model,
    required this.searchType,
    required this.onSelected,
    this.query = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(
        _iconForType(searchType),
        color: theme.colorScheme.primary,
      ),
      title: _highlightedTitle(theme),
      subtitle: Text(
        model.description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onSelected,
    );
  }

  IconData _iconForType(IdType type) => switch (type) {
        IdType.student => Icons.person_outline,
        IdType.lecturer => Icons.person_outline,
        IdType.group => Icons.groups_outlined,
        IdType.auditoriun => Icons.location_on_outlined,
        _ => Icons.search,
      };

  Widget _highlightedTitle(ThemeData theme) {
    final base =
        theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500);
    final queryLower = query.trim().toLowerCase();
    final label = model.label;
    if (queryLower.isEmpty) {
      return Text(label, style: base);
    }

    final spans = <TextSpan>[];
    final labelLower = label.toLowerCase();
    var start = 0;
    while (start <= labelLower.length) {
      final index = labelLower.indexOf(queryLower, start);
      if (index == -1) {
        spans.add(TextSpan(text: label.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: label.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: label.substring(index, index + queryLower.length),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            backgroundColor: theme.colorScheme.primary.withAlpha(31),
          ),
        ),
      );
      start = index + queryLower.length;
    }
    return Text.rich(TextSpan(children: spans), style: base);
  }
}
