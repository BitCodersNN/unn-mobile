// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/grade_formatters.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/expandable_subject_card.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/subject_detail.dart';

class GradeSubjectCard extends StatelessWidget {
  final MarkBySubject mark;

  const GradeSubjectCard({required this.mark, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markType = mark.markType;
    final date = mark.date;
    final color = theme.getColorOfMarkType(markType);
    return ExpandableSubjectCard(
      subject: mark.subject,
      caption: [
        if (date != null) DateFormat('dd.MM.yyyy').format(date),
        if (mark.controlType.trim().isNotEmpty) mark.controlType,
        if (date == null && mark.hours > 0)
          '${mark.hours} ч · ${mark.creditedHours} з. е.',
      ].join(' · '),
      trailing: markType == null
          ? null
          : Semantics(
              label: 'Оценка: ${markType.label}',
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.25,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  markType.labelFormatted,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
      details: [
        SubjectDetail(
          label: 'Преподаватель',
          value: mark.lecturers?.trim().isNotEmpty ?? false
              ? mark.lecturers!
              : '—',
        ),
        SubjectDetail(
          label: 'Трудоёмкость',
          value: mark.hours > 0
              ? '${mark.hours} ч · ${mark.creditedHours} з. е.'
              : '—',
        ),
      ],
    );
  }
}
