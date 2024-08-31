import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/schedule_search_suggestion_item.dart';

class ScheduleSearchSuggestionItemView extends StatelessWidget {
  final ScheduleSearchSuggestionItem model;

  final void Function() onSelected;
  const ScheduleSearchSuggestionItemView({
    super.key,
    required this.model,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      shape: const Border(bottom: BorderSide(color: Colors.black12)),
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
