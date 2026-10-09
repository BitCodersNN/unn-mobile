import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';

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
        type.label,
      _ => NumberFormat('0.#', 'ru_RU').format(type.value),
    };
