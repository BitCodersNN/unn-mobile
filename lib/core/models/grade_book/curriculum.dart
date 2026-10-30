// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/grade_book/curriculum_semester.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _JsonKeys {
  static const String semesters = 'semesters';
  static const String semester = 'semester';
}

class Curriculum {
  final Map<int, CurriculumSemester> semesters;

  Curriculum({required Map<int, CurriculumSemester> semesters})
    : semesters = Map.unmodifiable(<int, CurriculumSemester>{
        for (final number in semesters.keys.toList()..sort())
          number: semesters[number]!,
      });

  factory Curriculum.fromJson(
    List<Object?> json, {
    required LoggerService loggerService,
  }) {
    final semesters = <int, CurriculumSemester>{};
    final records = parseJsonIterable<Iterable<Object?>>(
      json,
      (plan) => plan[_JsonKeys.semesters] as Iterable<Object?>? ?? const [],
      loggerService,
    ).expand((records) => records);
    final parsedSemesters =
        parseJsonIterable<MapEntry<int, CurriculumSemester>>(
          records,
          (record) => MapEntry(
            (record[_JsonKeys.semester]! as num).toInt(),
            CurriculumSemester.fromJson(record, loggerService: loggerService),
          ),
          loggerService,
        );
    for (final entry in parsedSemesters) {
      final semester = entry.value;
      semesters.update(
        entry.key,
        (previous) => CurriculumSemester(
          mandatorySubjects: [
            ...previous.mandatorySubjects,
            ...semester.mandatorySubjects,
          ],
          electiveSubjects: [
            ...previous.electiveSubjects,
            ...semester.electiveSubjects,
          ],
        ),
        ifAbsent: () => semester,
      );
    }
    return Curriculum(semesters: semesters);
  }

  List<JsonMap> toJson() => [
    {
      _JsonKeys.semesters: [
        for (final entry in semesters.entries)
          {_JsonKeys.semester: entry.key, ...entry.value.toJson()},
      ],
    },
  ];
}
