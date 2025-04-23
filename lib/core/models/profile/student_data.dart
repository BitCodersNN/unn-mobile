// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/user_data.dart';

class _StudentDataJsonKeys {
  static const String eduForm = 'edu_form';
  static const String eduStatus = 'edu_status';
  static const String eduCourse = 'edu_course';
  static const String eduYear = 'edu_year';
  static const String eduLevel = 'edu_level';
  static const String faculty = 'faculty';
  static const String eduDirection = 'edu_direction';
  static const String eduGroup = 'edu_group';
  static const String eduSpecialization = 'edu_specialization';
  static const String title = 'title';
}

class StudentData extends UserData {
  final String _eduForm;
  final String _eduStatus;
  final int _eduCourse;
  final int _eduYear;
  final String _eduLevel;
  final String _faculty;
  final String _eduDirection;
  final String _eduGroup;
  final String? _eduSpecialization;

  StudentData(
    UserData userData,
    this._eduForm,
    this._eduStatus,
    this._eduCourse,
    this._eduYear,
    this._eduLevel,
    this._faculty,
    this._eduDirection,
    this._eduGroup,
    this._eduSpecialization,
  ) : super(
          userData.bitrixId,
          userData.login,
          userData.fullname,
          userData.email,
          userData.phone,
          userData.sex,
          userData.urlPhoto,
          userData.notes,
        );

  String get eduForm => _eduForm;
  String get eduStatus => _eduStatus;
  int get eduCourse => _eduCourse;
  int get eduYear => _eduYear;
  String get eduLevel => _eduLevel;
  String get faculty => _faculty;
  String get eduDirection => _eduDirection;
  String get eduGroup => _eduGroup;
  String? get eduSpecialization => _eduSpecialization;

  factory StudentData.fromJson(Map<String, Object?> jsonMap) {
    return StudentData(
      UserData.fromJson(jsonMap),
      jsonMap[_StudentDataJsonKeys.eduForm] as String,
      jsonMap[_StudentDataJsonKeys.eduStatus] as String,
      jsonMap[_StudentDataJsonKeys.eduCourse] as int,
      jsonMap[_StudentDataJsonKeys.eduYear] as int,
      jsonMap[_StudentDataJsonKeys.eduLevel] as String,
      (jsonMap[_StudentDataJsonKeys.faculty]
          as Map<String, Object?>)[_StudentDataJsonKeys.title] as String,
      (jsonMap[_StudentDataJsonKeys.eduDirection]
          as Map<String, Object?>)[_StudentDataJsonKeys.title] as String,
      (jsonMap[_StudentDataJsonKeys.eduGroup]
          as Map<String, Object?>)[_StudentDataJsonKeys.title] as String,
      (jsonMap[_StudentDataJsonKeys.eduSpecialization]
          as Map<String, Object?>?)?[_StudentDataJsonKeys.title] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json[_StudentDataJsonKeys.eduForm] = _eduForm;
    json[_StudentDataJsonKeys.eduStatus] = _eduStatus;
    json[_StudentDataJsonKeys.eduCourse] = _eduCourse;
    json[_StudentDataJsonKeys.eduYear] = _eduYear;
    json[_StudentDataJsonKeys.eduLevel] = _eduLevel;

    json[_StudentDataJsonKeys.faculty] ??= {};
    json[_StudentDataJsonKeys.faculty][_StudentDataJsonKeys.title] = _faculty;

    json[_StudentDataJsonKeys.eduDirection] ??= {};
    json[_StudentDataJsonKeys.eduDirection][_StudentDataJsonKeys.title] =
        _eduDirection;

    json[_StudentDataJsonKeys.eduGroup] ??= {};
    json[_StudentDataJsonKeys.eduGroup][_StudentDataJsonKeys.title] = _eduGroup;

    json[_StudentDataJsonKeys.eduSpecialization] ??= {};
    json[_StudentDataJsonKeys.eduSpecialization][_StudentDataJsonKeys.title] =
        _eduSpecialization;
    return json;
  }
}
