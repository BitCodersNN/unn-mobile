// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';

class ScheduleSearchSuggestionItemView extends StatelessWidget {
  final ScheduleSearchSuggestionItem model;

  final void Function() onSelected;
  const ScheduleSearchSuggestionItemView({
    required this.model,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      shape: Border(bottom: BorderSide(color: theme.dividerColor)),
      visualDensity: VisualDensity.compact,
      title: Text(model.label),
      subtitle: Text(
        model.description,
        style: theme.textTheme.labelSmall,
      ),
      onTap: onSelected,
    );
  }
}
