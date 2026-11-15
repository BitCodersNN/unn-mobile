// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_webinar_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/lessons/lesson_card.dart';
import 'package:unn_mobile/ui/widgets/lessons/lesson_detail.dart';
import 'package:unn_mobile/ui/widgets/lessons/lesson_time_range.dart';
import 'package:unn_mobile/ui/widgets/link_action.dart';
import 'package:unn_mobile/ui/widgets/linkified_text.dart';

class SourceWebinarView extends StatelessWidget {
  final SourceWebinarViewModel model;
  final bool even;

  const SourceWebinarView({required this.model, this.even = false, super.key});

  @override
  Widget build(BuildContext context) => BaseView<SourceWebinarViewModel>(
    model: model,
    builder: (context, model, _) {
      final duration = MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300);
      return Semantics(
        expanded: model.expanded,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => model.expanded = !model.expanded,
          child: AnimatedCrossFade(
            duration: duration,
            reverseDuration: duration,
            sizeCurve: Curves.easeInOutCubic,
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            crossFadeState: model.expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildCard(context, expanded: false),
            secondChild: _buildCard(context, expanded: true),
          ),
        ),
      );
    },
  );

  Widget _buildCard(BuildContext context, {required bool expanded}) {
    const horizontalPadding = 12.0;
    final theme = Theme.of(context);
    final stream = model.urlStream?.trim();
    final record = model.urlRecord?.trim();
    final hasStream = stream != null && stream.isNotEmpty;
    final hasRecord = record != null && record.isNotEmpty;
    return LessonCard(
      backgroundColor: theme.getScheduleSurfaceColor(
        model.dateTimeRange,
        isEven: even,
      ),
      accentColor: theme.getColorOfSubjectType(SubjectType.lab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      horizontalPadding,
                      10,
                      8,
                      10,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                model.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!expanded && (hasStream || hasRecord)) ...[
                          const SizedBox(height: 12),
                          LinkAction(
                            url: hasStream ? stream : record!,
                            label: hasStream ? 'Трансляция' : 'Запись',
                            child: Text(
                              hasStream ? stream : record!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                        if (expanded) ...[
                          if (model.discipline.isNotEmpty &&
                              model.discipline != model.title) ...[
                            const SizedBox(height: 12),
                            LessonDetail(
                              icon: Icons.school_outlined,
                              text: model.discipline,
                              expanded: true,
                            ),
                          ],
                          if (model.comment.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            LinkifiedText(
                              text: model.comment,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    0,
                    10,
                    horizontalPadding,
                    10,
                  ),
                  child: LessonTimeRange(range: model.dateTimeRange),
                ),
              ],
            ),
          ),
          if (expanded && (hasStream || hasRecord))
            Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                4,
                horizontalPadding,
                12,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasStream)
                      Expanded(
                        child: _WebinarButton(
                          url: stream,
                          label: 'Подключиться',
                          icon: Icons.videocam_outlined,
                        ),
                      ),
                    if (hasStream && hasRecord) const SizedBox(width: 8),
                    if (hasRecord)
                      Expanded(
                        child: _WebinarButton(
                          url: record,
                          label: 'Запись',
                          icon: Icons.play_circle_outline,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WebinarButton extends StatelessWidget {
  final String url;
  final String label;
  final IconData icon;

  const _WebinarButton({
    required this.url,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return LinkAction(
      url: url,
      label: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
