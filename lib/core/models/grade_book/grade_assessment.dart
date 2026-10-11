// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';

enum GradeResultGroup { grades, credits }

extension GradeAssessment on MarkBySubject {
  String get _normalizedControl =>
      controlType.toLowerCase().replaceAll('ё', 'е');

  bool get isExam => _normalizedControl.contains('экзамен');

  bool get isCreditControl => _normalizedControl.contains('зачет');

  bool get requiresRetake => markType?.requiresRetake ?? false;

  double? get averageValue => (markType?.isNumeric ?? false) && !isCreditControl
      ? markType?.value
      : null;

  GradeResultGroup get resultGroup => (markType?.isCredit ?? false) ||
          (markType == MarkType.noShow && isCreditControl)
      ? GradeResultGroup.credits
      : GradeResultGroup.grades;
}
