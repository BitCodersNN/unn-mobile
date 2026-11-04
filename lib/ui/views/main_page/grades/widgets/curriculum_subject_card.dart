// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/grade_book/curriculum_subject.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/expandable_subject_card.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/subject_detail.dart';

class CurriculumSubjectCard extends StatelessWidget {
  final CurriculumSubject subject;

  const CurriculumSubjectCard({required this.subject, super.key});

  @override
  Widget build(BuildContext context) => ExpandableSubjectCard(
    subject: subject.subject,
    caption: [
      if (subject.controlType.trim().isNotEmpty) subject.controlType,
      if (subject.hours > 0)
        '${subject.hours} ч · ${subject.creditedHours} з. е.',
    ].join(' · '),
    details: [
      SubjectDetail(
        label: 'Лекции',
        value: '${subject.hoursBreakdown.lectures} ч',
      ),
      SubjectDetail(
        label: 'Практические занятия',
        value: '${subject.hoursBreakdown.practice} ч',
      ),
      SubjectDetail(
        label: 'Лабораторные работы',
        value: '${subject.hoursBreakdown.labs} ч',
      ),
      SubjectDetail(
        label: 'Самостоятельная работа',
        value: '${subject.hoursBreakdown.independent} ч',
      ),
    ],
  );
}
