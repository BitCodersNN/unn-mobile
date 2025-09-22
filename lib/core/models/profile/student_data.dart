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
  final String eduForm;
  final String eduStatus;
  final int eduCourse;
  final int eduYear;
  final String eduLevel;
  final String faculty;
  final String eduDirection;
  final String eduGroup;
  final String? eduSpecialization;

  StudentData({
    required super.bitrixId,
    required super.fullname,
    required super.photoSrc,
    required super.userId,
    required super.login,
    required super.email,
    required super.phone,
    required super.sex,
    required super.notes,
    required this.eduForm,
    required this.eduStatus,
    required this.eduCourse,
    required this.eduYear,
    required this.eduLevel,
    required this.faculty,
    required this.eduDirection,
    required this.eduGroup,
    required this.eduSpecialization,
  });

  StudentData.withUserData({
    required UserData userData,
    required this.eduForm,
    required this.eduStatus,
    required this.eduCourse,
    required this.eduYear,
    required this.eduLevel,
    required this.faculty,
    required this.eduDirection,
    required this.eduGroup,
    this.eduSpecialization,
  }) : super(
          userId: userData.userId,
          bitrixId: userData.bitrixId,
          login: userData.login,
          fullname: userData.fullname,
          email: userData.email,
          phone: userData.phone,
          sex: userData.sex,
          photoSrc: userData.photoSrc,
          notes: userData.notes,
        );

  factory StudentData.fromJson(Map<String, Object?> jsonMap) =>
      StudentData.withUserData(
        userData: UserData.fromJson(jsonMap),
        eduForm: jsonMap[_StudentDataJsonKeys.eduForm] as String,
        eduStatus: jsonMap[_StudentDataJsonKeys.eduStatus] as String,
        eduCourse: jsonMap[_StudentDataJsonKeys.eduCourse] as int,
        eduYear: jsonMap[_StudentDataJsonKeys.eduYear] as int,
        eduLevel: jsonMap[_StudentDataJsonKeys.eduLevel] as String,
        faculty: (jsonMap[_StudentDataJsonKeys.faculty]
            as Map<String, Object?>)[_StudentDataJsonKeys.title] as String,
        eduDirection: (jsonMap[_StudentDataJsonKeys.eduDirection]
            as Map<String, Object?>)[_StudentDataJsonKeys.title] as String,
        eduGroup: (jsonMap[_StudentDataJsonKeys.eduGroup]
            as Map<String, Object?>)[_StudentDataJsonKeys.title] as String,
        eduSpecialization: (jsonMap[_StudentDataJsonKeys.eduSpecialization]
            as Map<String, Object?>?)?[_StudentDataJsonKeys.title] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        _StudentDataJsonKeys.eduForm: eduForm,
        _StudentDataJsonKeys.eduStatus: eduStatus,
        _StudentDataJsonKeys.eduCourse: eduCourse,
        _StudentDataJsonKeys.eduYear: eduYear,
        _StudentDataJsonKeys.eduLevel: eduLevel,
        _StudentDataJsonKeys.faculty: {
          _StudentDataJsonKeys.title: faculty,
        },
        _StudentDataJsonKeys.eduDirection: {
          _StudentDataJsonKeys.title: eduDirection,
        },
        _StudentDataJsonKeys.eduGroup: {
          _StudentDataJsonKeys.title: eduGroup,
        },
        _StudentDataJsonKeys.eduSpecialization: {
          _StudentDataJsonKeys.title: eduSpecialization,
        },
      };
}
