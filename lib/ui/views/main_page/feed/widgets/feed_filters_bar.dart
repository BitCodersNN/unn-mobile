import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/feed/feed_filter.dart';

class FeedFiltersBar extends StatelessWidget {
  final FeedFilter selected;
  final ValueChanged<FeedFilter>? onSelected;

  const FeedFiltersBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          for (final filter in FeedFilter.values)
            Expanded(
              child: ChoiceChip(
                label: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.textScalerOf(context).scale(32),
                  child: Center(
                    child: Text(
                      filter.caption,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                selected: selected == filter,
                showCheckmark: false,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedColor: colors.primary,
                backgroundColor: colors.surfaceContainerLowest,
                labelStyle: TextStyle(
                  color: selected == filter
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: selected == filter
                      ? Colors.transparent
                      : colors.outlineVariant,
                ),
                onSelected:
                    onSelected == null ? null : (_) => onSelected!(filter),
              ),
            ),
        ],
      ),
    );
  }
}
