import 'package:flutter/material.dart';

class ScheduleSearchSuggestionItem extends StatelessWidget {
  final String itemName;

  final String? itemDescription;
  final void Function() onSelected;
  const ScheduleSearchSuggestionItem(
      {super.key,
      required this.itemName,
      this.itemDescription,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            child: Text(itemName),
          ),
          if (itemDescription != null)
            Positioned(
              top: 20,
              child: Text(
                itemDescription!,
                style: theme.textTheme.labelSmall,
              ),
            ),
        ],
      ),
      onTap: onSelected,
    );
  }
}
