// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/tree_flattener.dart';
import 'package:unn_mobile/core/models/profile/employee/department.dart';

class _BaeEmployeeProfileJsonKeys {
  static const String id = 'id';
  static const String departmentId = 'department_id';
  static const String jobTitle = 'job_title';
  static const String department = 'department';
  static const String child = 'child';
}

class BaeEmployeeProfile {
  final int id;
  final int? departmentId;
  final String jobTitle;
  final List<Department> departments;

  BaeEmployeeProfile({
    required this.id,
    required this.departmentId,
    required this.jobTitle,
    required this.departments,
  });

  factory BaeEmployeeProfile.fromJson(Map<String, Object?> json) =>
      BaeEmployeeProfile(
        id: json[_BaeEmployeeProfileJsonKeys.id] as int,
        departmentId: int.tryParse(
          json[_BaeEmployeeProfileJsonKeys.departmentId] as String,
        ),
        jobTitle: json[_BaeEmployeeProfileJsonKeys.jobTitle] as String,
        departments: (json[_BaeEmployeeProfileJsonKeys.department] as List)
            .map((item) => Department.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  factory BaeEmployeeProfile.fromProfileJson(Map<String, Object?> json) =>
      BaeEmployeeProfile(
        id: json[_BaeEmployeeProfileJsonKeys.id] as int,
        departmentId: int.tryParse(
          json[_BaeEmployeeProfileJsonKeys.departmentId] as String,
        ),
        jobTitle: json[_BaeEmployeeProfileJsonKeys.jobTitle] as String,
        departments: (flattenTree(
          json: json[_BaeEmployeeProfileJsonKeys.department]
              as Map<String, dynamic>,
          rootKey: _BaeEmployeeProfileJsonKeys.department,
          childKey: _BaeEmployeeProfileJsonKeys.child,
        )).map((item) => Department.fromJson(item)).toList(),
      );
}
