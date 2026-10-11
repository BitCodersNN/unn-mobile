// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/grade_book/grade_assessment.dart';
import 'package:unn_mobile/core/models/grade_book/grade_distribution.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_details_popover.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_style.dart';

class GradeDistributionBar extends StatelessWidget {
  final List<GradeDistributionEntry> entries;
  final Object? selected;
  final GradeDetailsCallback? onShowDetails;

  const GradeDistributionBar({
    required this.entries,
    this.selected,
    this.onShowDetails,
    super.key,
  });

  @override
  Widget build(BuildContext context) => onShowDetails != null
      ? _buildBar(context, selected, onShowDetails!)
      : GradeDetailsPopover(
          builder: (context, selected, showDetails, _) =>
              _buildBar(context, selected, showDetails),
        );

  Widget _buildBar(
    BuildContext context,
    Object? selected,
    GradeDetailsCallback showDetails,
  ) {
    if (entries.isEmpty) {
      return const Padding(padding: EdgeInsets.only(top: 8), child: Text('—'));
    }
    return SizedBox(
      height: 40,
      child: Row(
        spacing: 3,
        children: [
          for (final entry in entries)
            Expanded(
              flex: entry.count,
              child: Builder(
                builder: (context) => Semantics(
                  button: true,
                  selected: selected == entry,
                  label: '${entry.type.label}, ${entry.count}',
                  child: GestureDetector(
                    key: ValueKey(
                      'grade-segment-${entry.group.name}-${entry.type.name}',
                    ),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => showDetails(
                      context,
                      entry,
                      _DistributionDetails(entry: entry),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        key: ValueKey(
                          'grade-segment-fill-${entry.group.name}-${entry.type.name}',
                        ),
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeInOutCubic,
                        height: selected == entry ? 14 : 8,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Theme.of(context).getColorOfMarkType(entry.type),
                            Colors.white,
                            0.3,
                          )!
                              .withValues(
                            alpha:
                                selected == null || selected == entry ? 1 : 0.5,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          border: selected == entry
                              ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withValues(alpha: 0.85),
                                )
                              : null,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DistributionDetails extends StatelessWidget {
  final GradeDistributionEntry entry;

  const _DistributionDetails({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = entry.group == GradeResultGroup.grades ? 'оценок' : 'зачётов';
    final percentage = NumberFormat('0.##', 'ru_RU').format(entry.percentage);
    return Column(
      key: const ValueKey('grade-distribution-details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${gradeLabel(entry.type)}${entry.type.isNumeric ? ' · ${entry.type.label}' : ''}',
          style: theme.textTheme.titleSmall
              ?.copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 6),
        Text(
          '$percentage% среди $group · ${entry.count} из ${entry.total}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
