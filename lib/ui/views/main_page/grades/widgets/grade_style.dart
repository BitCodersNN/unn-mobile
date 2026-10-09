import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';

const gradeDistributionOrder = [
  MarkType.perfect,
  MarkType.excellent,
  MarkType.veryGood,
  MarkType.good,
  MarkType.satisfactory,
  MarkType.notSatisfactory,
  MarkType.credited,
  MarkType.notCredited,
  MarkType.noShow,
];

String formatGradeAverage(double? average) =>
    average == null ? '—' : NumberFormat('0.00', 'ru_RU').format(average);

String gradeLabel(MarkType type) => switch (type) {
      MarkType.credited ||
      MarkType.notCredited ||
      MarkType.noShow =>
        type.convertToString(),
      _ => NumberFormat('0.#', 'ru_RU').format(type.convertToDouble()),
    };

Color gradeColor(MarkType type) => switch (type) {
      MarkType.perfect || MarkType.excellent => const Color(0xFF15803D),
      MarkType.veryGood || MarkType.good => const Color(0xFF9A6700),
      MarkType.satisfactory => const Color(0xFFB45309),
      MarkType.notSatisfactory ||
      MarkType.notCredited =>
        const Color(0xFFB42318),
      MarkType.credited => const Color(0xFF2563EB),
      MarkType.noShow => const Color(0xFF64748B),
    };
