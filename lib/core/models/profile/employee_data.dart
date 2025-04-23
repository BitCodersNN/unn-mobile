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
  final String _syncID;
  final String _jobType;
  final String _jobTitle;
  final String _department;
  final String? _manager;

  EmployeeData(
    UserData userData,
    this._syncID,
    this._jobType,
    this._jobTitle,
    this._department,
    this._manager,
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

  String get syncID => _syncID;
  String get jobType => _jobType;
  String get jobTitle => _jobTitle;
  String get department => _department;
  String? get manager => _manager;

  factory EmployeeData.fromJson(Map<String, Object?> jsonMap) {
    return EmployeeData(
      UserData.fromJson(jsonMap),
      (jsonMap[_EmployeeDataJsonKeys.user]
          as Map<String, Object?>)[_EmployeeDataJsonKeys.syncID] as String,
      jsonMap[_EmployeeDataJsonKeys.jobType] as String,
      jsonMap[_EmployeeDataJsonKeys.jobTitle] as String,
      (jsonMap[_EmployeeDataJsonKeys.department]
          as Map<String, Object?>)[_EmployeeDataJsonKeys.title] as String,
      (jsonMap[_EmployeeDataJsonKeys.manager]
          as Map<String, Object?>?)?[_EmployeeDataJsonKeys.fullname] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json[_EmployeeDataJsonKeys.user][_EmployeeDataJsonKeys.syncID] = _syncID;
    json[_EmployeeDataJsonKeys.jobType] = _jobType;
    json[_EmployeeDataJsonKeys.jobTitle] = _jobTitle;
    json[_EmployeeDataJsonKeys.department] ??= {};
    json[_EmployeeDataJsonKeys.department][_EmployeeDataJsonKeys.title] =
        _department;
    json[_EmployeeDataJsonKeys.manager] ??= {};
    json[_EmployeeDataJsonKeys.manager][_EmployeeDataJsonKeys.fullname] =
        _manager;
    return json;
  }
}
