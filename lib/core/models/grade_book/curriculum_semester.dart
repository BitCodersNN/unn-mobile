// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _JsonKeys {
  static const String semester = 'semester';
  static const String mandatorySubjects = 'mandatory_subjects';
  static const String electiveSubjects = 'elective_subjects';
  static const String sections = 'sections';
  static const String id = 'id';
  static const String parentId = 'parent_id';
  static const String type = 'type';
  static const String title = 'title';
  static const String hours = 'hours';
  static const String elective = 'elective';
  static const String deletionMark = 'deletion_mark';
  static const String terms = 'terms';
  static const String termNumber = 'num';

  static const Map<String, String> controlTypes = {
    'exam': 'Экзамен',
    'test': 'Зачёт',
    'testdif': 'Дифференцированный зачёт',
    'kp': 'Курсовой проект',
    'kr': 'Курсовая работа',
    'testwork': 'Контрольная работа',
  };
}

class CurriculumSemester {
  final List<MarkBySubject> mandatorySubjects;
  final List<MarkBySubject> electiveSubjects;

  CurriculumSemester({
    required Iterable<MarkBySubject> mandatorySubjects,
    required Iterable<MarkBySubject> electiveSubjects,
  }) : mandatorySubjects = List.unmodifiable(mandatorySubjects),
       electiveSubjects = List.unmodifiable(electiveSubjects);

  factory CurriculumSemester.fromJson(
    JsonMap json, {
    required LoggerService loggerService,
  }) {
    if (json.containsKey(_JsonKeys.sections)) {
      return CurriculumSemester._fromSections(json);
    }
    return CurriculumSemester(
      mandatorySubjects: parseJsonIterable<MarkBySubject>(
        json[_JsonKeys.mandatorySubjects] as Iterable<Object?>? ?? const [],
        MarkBySubject.fromJson,
        loggerService,
      ),
      electiveSubjects: parseJsonIterable<MarkBySubject>(
        json[_JsonKeys.electiveSubjects] as Iterable<Object?>? ?? const [],
        MarkBySubject.fromJson,
        loggerService,
      ),
    );
  }

  factory CurriculumSemester._fromSections(JsonMap json) {
    final number = (json[_JsonKeys.semester]! as num).toInt();
    final sections = _objects(json[_JsonKeys.sections]).toList();
    final sectionsById = <int, JsonMap>{
      for (final section in sections)
        if (section[_JsonKeys.id] case final num id) id.toInt(): section,
    };
    final mandatorySubjects = <MarkBySubject>[];
    final electiveSubjects = <MarkBySubject>[];
    for (final section in sections) {
      if (section[_JsonKeys.type] == 'section') {
        continue;
      }
      final terms = _objects(section[_JsonKeys.terms])
          .where(
            (term) => (term[_JsonKeys.termNumber] as num?)?.toInt() == number,
          )
          .toList();
      if (terms.isEmpty) {
        continue;
      }
      final ancestors = _sectionPath(section, sectionsById).toList();
      if (ancestors.any((node) => _enabled(node[_JsonKeys.deletionMark]))) {
        continue;
      }
      final subject = _parseSubject(section, terms);
      final isElective =
          ancestors.any((node) => _enabled(node[_JsonKeys.elective])) ||
          terms.any((term) => _enabled(term[_JsonKeys.elective]));
      (isElective ? electiveSubjects : mandatorySubjects).add(subject);
    }
    return CurriculumSemester(
      mandatorySubjects: mandatorySubjects,
      electiveSubjects: electiveSubjects,
    );
  }

  JsonMap toJson() => {
    _JsonKeys.mandatorySubjects: mandatorySubjects
        .map((subject) => subject.toJson())
        .toList(),
    _JsonKeys.electiveSubjects: electiveSubjects
        .map((subject) => subject.toJson())
        .toList(),
  };

  static MarkBySubject _parseSubject(JsonMap section, List<JsonMap> terms) =>
      MarkBySubject(
        controlType: [
          for (final control in _JsonKeys.controlTypes.entries)
            if (terms.any((term) => _enabled(term[control.key]))) control.value,
        ].join(', '),
        date: null,
        hours: (section[_JsonKeys.hours]! as num).toInt(),
        lecturers: null,
        markType: null,
        subject: section[_JsonKeys.title]! as String,
      );

  static Iterable<JsonMap> _objects(Object? value) =>
      (value as Iterable<Object?>? ?? const []).cast<JsonMap>();

  static bool _enabled(Object? value) =>
      value == true || (value is num && value > 0);

  static Iterable<JsonMap> _sectionPath(
    JsonMap section,
    Map<int, JsonMap> sectionsById,
  ) sync* {
    final visited = <int>{};
    JsonMap? current = section;
    while (current != null) {
      final id = (current[_JsonKeys.id] as num?)?.toInt();
      if (id != null && !visited.add(id)) {
        throw FormatException('Cyclic curriculum section hierarchy', id);
      }
      yield current;
      final parent = (current[_JsonKeys.parentId] as num?)?.toInt();
      current = parent == null || parent == 0 ? null : sectionsById[parent];
    }
  }
}
