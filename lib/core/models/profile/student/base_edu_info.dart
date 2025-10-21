// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

class _BaseEduInfoJsonKeys {
  static const String eduForm = 'edu_form';
  static const String eduCourse = 'edu_course';
  static const String eduLevel = 'edu_level';
  static const String eduDirection = 'edu_direction';
  static const String eduGroup = 'edu_group';
  static const String eduSpecialization = 'edu_specialization';
  static const String department = 'department';
  static const String faculty = 'faculty';
  static const String title = 'title';
}

/// Базовая информация об образовании студента на портале.
///
/// Содержит основные атрибуты, описывающие текущее состояние обучения:
/// форму обучения, курс, уровень образования, факультет, направление подготовки,
/// учебную группу и, при наличии, специализацию.
class BaseEduInfo {
  final String eduForm;
  final int eduCourse;
  final String eduLevel;
  final String faculty;
  final String eduDirection;
  final String eduGroup;
  final String? eduSpecialization;

  BaseEduInfo({
    required this.eduForm,
    required this.eduCourse,
    required this.eduLevel,
    required this.faculty,
    required this.eduDirection,
    required this.eduGroup,
    required this.eduSpecialization,
  });

  JsonMap toJson() => {
        _BaseEduInfoJsonKeys.eduForm: eduForm,
        _BaseEduInfoJsonKeys.eduCourse: eduCourse,
        _BaseEduInfoJsonKeys.eduLevel: eduLevel,
        _BaseEduInfoJsonKeys.faculty: {
          _BaseEduInfoJsonKeys.title: faculty,
        },
        _BaseEduInfoJsonKeys.eduDirection: {
          _BaseEduInfoJsonKeys.title: eduDirection,
        },
        _BaseEduInfoJsonKeys.eduGroup: {
          _BaseEduInfoJsonKeys.title: eduGroup,
        },
        _BaseEduInfoJsonKeys.eduSpecialization: {
          _BaseEduInfoJsonKeys.title: eduSpecialization,
        },
      };

  JsonMap toPreviewStudentJson() => {
        _BaseEduInfoJsonKeys.eduForm: eduForm,
        _BaseEduInfoJsonKeys.eduCourse: eduCourse,
        _BaseEduInfoJsonKeys.eduLevel: eduLevel,
        _BaseEduInfoJsonKeys.department: faculty,
        _BaseEduInfoJsonKeys.eduDirection: eduDirection,
        _BaseEduInfoJsonKeys.eduGroup: eduGroup,
        _BaseEduInfoJsonKeys.eduSpecialization: eduSpecialization,
      };

  factory BaseEduInfo.fromJson(JsonMap jsonMap) => BaseEduInfo(
        eduForm: jsonMap[_BaseEduInfoJsonKeys.eduForm]! as String,
        eduCourse: jsonMap[_BaseEduInfoJsonKeys.eduCourse]! as int,
        eduLevel: jsonMap[_BaseEduInfoJsonKeys.eduLevel]! as String,
        faculty: (jsonMap[_BaseEduInfoJsonKeys.faculty]!
            as JsonMap)[_BaseEduInfoJsonKeys.title]! as String,
        eduDirection: (jsonMap[_BaseEduInfoJsonKeys.eduDirection]!
            as JsonMap)[_BaseEduInfoJsonKeys.title]! as String,
        eduGroup: (jsonMap[_BaseEduInfoJsonKeys.eduGroup]!
            as JsonMap)[_BaseEduInfoJsonKeys.title]! as String,
        eduSpecialization: (jsonMap[_BaseEduInfoJsonKeys.eduSpecialization]
            as JsonMap?)?[_BaseEduInfoJsonKeys.title] as String?,
      );

  factory BaseEduInfo.previewStudentfromJson(JsonMap json) => BaseEduInfo(
        eduForm: json[_BaseEduInfoJsonKeys.eduForm]! as String,
        eduCourse: json[_BaseEduInfoJsonKeys.eduCourse]! as int,
        eduLevel: json[_BaseEduInfoJsonKeys.eduLevel]! as String,
        faculty: json[_BaseEduInfoJsonKeys.department]! as String,
        eduDirection: json[_BaseEduInfoJsonKeys.eduDirection]! as String,
        eduGroup: json[_BaseEduInfoJsonKeys.eduGroup]! as String,
        eduSpecialization:
            json[_BaseEduInfoJsonKeys.eduSpecialization] as String?,
      );
}
