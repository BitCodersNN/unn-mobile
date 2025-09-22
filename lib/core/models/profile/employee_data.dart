// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/user_data.dart';

class _EmployeeDataJsonKeys {
  static const String user = 'user';
  static const String syncID = 'sync_id';
  static const String jobType = 'job_type';
  static const String jobTitle = 'job_title';
  static const String department = 'department';
  static const String title = 'title';
  static const String manager = 'manager';
  static const String fullname = 'fullname';
}

class EmployeeData extends UserData {
  final String syncID;
  final String jobType;
  final String jobTitle;
  final String department;
  final String? manager;

  EmployeeData({
    required super.bitrixId,
    required super.fullname,
    required super.photoSrc,
    required super.login,
    required super.email,
    required super.phone,
    required super.sex,
    required super.notes,
    required this.syncID,
    required this.jobType,
    required this.jobTitle,
    required this.department,
    required this.manager,
  });

  EmployeeData.withUserData({
    required UserData userData,
    required this.syncID,
    required this.jobType,
    required this.jobTitle,
    required this.department,
    this.manager,
  }) : super(
          bitrixId: userData.bitrixId,
          login: userData.login,
          fullname: userData.fullname,
          email: userData.email,
          phone: userData.phone,
          sex: userData.sex,
          photoSrc: userData.photoSrc,
          notes: userData.notes,
        );

  factory EmployeeData.fromJson(Map<String, Object?> jsonMap) =>
      EmployeeData.withUserData(
        userData: UserData.fromJson(jsonMap),
        syncID: (jsonMap[_EmployeeDataJsonKeys.user]
            as Map<String, Object?>)[_EmployeeDataJsonKeys.syncID] as String,
        jobType: jsonMap[_EmployeeDataJsonKeys.jobType] as String,
        jobTitle: jsonMap[_EmployeeDataJsonKeys.jobTitle] as String,
        department: (jsonMap[_EmployeeDataJsonKeys.department]
            as Map<String, Object?>)[_EmployeeDataJsonKeys.title] as String,
        manager: (jsonMap[_EmployeeDataJsonKeys.manager]
                as Map<String, Object?>?)?[_EmployeeDataJsonKeys.fullname]
            as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
        _EmployeeDataJsonKeys.user: {
          ...super.toJson()[_EmployeeDataJsonKeys.user],
          _EmployeeDataJsonKeys.syncID: syncID,
        },
        _EmployeeDataJsonKeys.jobType: jobType,
        _EmployeeDataJsonKeys.jobTitle: jobTitle,
        _EmployeeDataJsonKeys.department: {
          _EmployeeDataJsonKeys.title: department,
        },
        _EmployeeDataJsonKeys.manager: {
          _EmployeeDataJsonKeys.fullname: manager,
        },
      };
}
