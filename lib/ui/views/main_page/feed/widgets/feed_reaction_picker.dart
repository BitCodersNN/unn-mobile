import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';

class FeedReactionPicker extends StatelessWidget {
  final ReactionType? selected;
  final ValueChanged<ReactionType> onSelected;
  final double elevation;

  const FeedReactionPicker({
    required this.selected,
    required this.onSelected,
    this.elevation = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
        elevation: elevation,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              for (final reaction in ReactionType.values)
                IconButton(
                  tooltip: reaction.caption,
                  isSelected: selected == reaction,
                  style: IconButton.styleFrom(
                    backgroundColor: selected == reaction
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Colors.transparent,
                  ),
                  onPressed: () => onSelected(reaction),
                  icon: Image.asset(reaction.assetName, width: 32, height: 32),
                ),
            ],
          ),
        ),
      );
}
