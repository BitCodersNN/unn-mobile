// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/tree_flattener.dart';
import 'package:unn_mobile/core/models/profile/employee/department.dart';

class _BaseEmployeeProfileJsonKeys {
  static const String id = 'id';
  static const String departmentId = 'department_id';
  static const String jobTitle = 'job_title';
  static const String department = 'department';
  static const String child = 'child';
}

class BaseEmployeeProfile {
  final int id;
  final int? departmentId;
  final String jobTitle;
  final List<Department> departments;

  BaseEmployeeProfile({
    required this.id,
    required this.departmentId,
    required this.jobTitle,
    required this.departments,
  });

  Map<String, dynamic> toJson() => {
        _BaseEmployeeProfileJsonKeys.id: id,
        _BaseEmployeeProfileJsonKeys.departmentId: departmentId?.toString(),
        _BaseEmployeeProfileJsonKeys.jobTitle: jobTitle,
        _BaseEmployeeProfileJsonKeys.department:
            departments.map((department) => department.toJson()).toList(),
      };

  factory BaseEmployeeProfile.fromJson(Map<String, Object?> json) =>
      BaseEmployeeProfile(
        id: json[_BaseEmployeeProfileJsonKeys.id] as int,
        departmentId: json[_BaseEmployeeProfileJsonKeys.departmentId] != null
            ? int.tryParse(
                json[_BaseEmployeeProfileJsonKeys.departmentId] as String,
              )
            : null,
        jobTitle: json[_BaseEmployeeProfileJsonKeys.jobTitle] as String,
        departments: _parseDepartments(
          json[_BaseEmployeeProfileJsonKeys.department],
        ),
      );

  static List<Department> _parseDepartments(dynamic departmentJson) {
    if (departmentJson == null) {
      return [];
    }

    Iterable<Map<String, dynamic>> departmentMaps;

    if (departmentJson is List) {
      departmentMaps = departmentJson.whereType<Map<String, dynamic>>();
    } else if (departmentJson is Map<String, dynamic>) {
      departmentMaps = flattenTree(
        json: departmentJson,
        rootKey: _BaseEmployeeProfileJsonKeys.department,
        childKey: _BaseEmployeeProfileJsonKeys.child,
      ).whereType<Map<String, dynamic>>();
    } else {
      return [];
    }

    return departmentMaps.map(Department.fromJson).toList();
  }
}
