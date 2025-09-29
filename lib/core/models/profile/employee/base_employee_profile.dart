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

  Map<String, dynamic> toJson() => {
        _BaeEmployeeProfileJsonKeys.id: id,
        _BaeEmployeeProfileJsonKeys.departmentId: departmentId?.toString(),
        _BaeEmployeeProfileJsonKeys.jobTitle: jobTitle,
        _BaeEmployeeProfileJsonKeys.department:
            departments.map((department) => department.toJson()).toList(),
      };

  factory BaeEmployeeProfile.fromJson(Map<String, Object?> json) =>
      BaeEmployeeProfile(
        id: json[_BaeEmployeeProfileJsonKeys.id] as int,
        departmentId: json[_BaeEmployeeProfileJsonKeys.departmentId] != null
            ? int.tryParse(
                json[_BaeEmployeeProfileJsonKeys.departmentId] as String,
              )
            : null,
        jobTitle: json[_BaeEmployeeProfileJsonKeys.jobTitle] as String,
        departments: _parseDepartments(
          json[_BaeEmployeeProfileJsonKeys.department],
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
        rootKey: _BaeEmployeeProfileJsonKeys.department,
        childKey: _BaeEmployeeProfileJsonKeys.child,
      ).whereType<Map<String, dynamic>>();
    } else {
      return [];
    }

    return departmentMaps.map(Department.fromJson).toList();
  }
}
