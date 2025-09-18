// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/bounded_int.dart';
import 'package:unn_mobile/core/misc/camel_case_converter.dart';

class _FilterNames {
  static const String global = 'global';
  static const String fullname = 'fullname';
  static const String eduLevel = 'edu_level';
  static const String eduCourse = 'edu_course';
  static const String eduForm = 'edu_form';
  static const String eduYear = 'edu_year';
}

class _MatchMode {
  static const String key = 'matchMode';
  static const String any = 'any';
  static const String contains = 'contains';
}

class SearchFilter {
  final Map<String, dynamic> filters;

  SearchFilter({
    String? globalFilter,
    String? fullname,
    EduLevel? eduLevel,
    EduCourse? eduCourse,
    EduForm? eduForm,
    EduYear? eduYear,
  }) : filters = _buildFilters(
          globalFilter: globalFilter,
          fullname: fullname,
          eduLevel: eduLevel?.name,
          eduCourse: eduCourse?.value,
          eduForm: eduForm?.name.toKebabCase(),
          eduYear: eduYear?.value,
        );

  static Map<String, dynamic> _buildFilters({
    String? globalFilter,
    String? fullname,
    String? eduLevel,
    int? eduCourse,
    String? eduForm,
    int? eduYear,
  }) {
    final filters = <String, dynamic>{
      _FilterNames.global: {
        _MatchMode.key: _MatchMode.contains,
        'value': globalFilter,
      },
    };

    void addFilter(String key, dynamic value) {
      if (value != null) {
        filters[key] = {_MatchMode.key: _MatchMode.any, 'value': value};
      }
    }

    addFilter(_FilterNames.fullname, fullname);
    addFilter(_FilterNames.eduLevel, eduLevel);
    addFilter(_FilterNames.eduCourse, eduCourse);
    addFilter(_FilterNames.eduForm, eduForm);
    addFilter(_FilterNames.eduYear, eduYear);

    return filters;
  }

  String? get globalFilter => filters[_FilterNames.global]['value'];
}

class EduCourse extends BoundedInt {
  EduCourse(int value)
      : super(
          value: value,
          min: 1,
          max: 6,
          paramName: _FilterNames.eduCourse,
          errorMessage: 'Учебный год должен быть от 1 до 6',
        );

  EduCourse.first() : this(1);
  EduCourse.last() : this(6);
}

class EduYear extends BoundedInt {
  EduYear(int value)
      : super(
          value: value,
          min: 2000,
          max: DateTime.now().year,
          paramName: _FilterNames.eduYear,
          errorMessage:
              'Учебный год должен быть от 2000 до ${DateTime.now().year}',
        );

  EduYear.current() : this(DateTime.now().year);

  EduYear.firstSupported() : this(2000);
}

enum EduLevel {
  graduateStudent,
  basicLevel,
  bachelor,
  master,
  residency,
  professionalDevelopment,
  increasedLevel,
  preparatoryDepartment,
  specialist,
  spo,
  ;

  String get name => _displayNames[this]!;
}

enum EduForm {
  fullTime,
  distance,
  partTime,
}

const Map<EduLevel, String> _displayNames = {
  EduLevel.graduateStudent: 'Аспирант',
  EduLevel.basicLevel: 'Базовый уровень',
  EduLevel.bachelor: 'Бакалавр',
  EduLevel.master: 'Магистр',
  EduLevel.residency: 'Ординатура',
  EduLevel.professionalDevelopment: 'Повышение квалификации',
  EduLevel.increasedLevel: 'Повышенный уровень',
  EduLevel.preparatoryDepartment: 'Подготовительное отделение',
  EduLevel.specialist: 'Специалист',
  EduLevel.spo: 'СПО',
};
