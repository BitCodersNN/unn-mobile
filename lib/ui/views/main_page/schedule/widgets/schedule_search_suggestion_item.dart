import 'package:flutter/material.dart';

class ScheduleSearchSuggestionItem extends StatelessWidget {
  final String itemName;

  final String? itemDescription;
  final void Function() onSelected;
  const ScheduleSearchSuggestionItem({
    super.key,
    required this.itemName,
    this.itemDescription,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      shape: const Border(bottom: BorderSide(color: Colors.black12)),
      visualDensity: VisualDensity.compact,
      title: Text(itemName),
      subtitle: itemDescription != null
          ? Text(
              itemDescription!,
              style: theme.textTheme.labelSmall,
            )
          : null,
      onTap: onSelected,
    );
  }
}
