// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
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

  JsonMap toJson() => {
        _BaseEmployeeProfileJsonKeys.id: id,
        _BaseEmployeeProfileJsonKeys.departmentId: departmentId?.toString(),
        _BaseEmployeeProfileJsonKeys.jobTitle: jobTitle,
        _BaseEmployeeProfileJsonKeys.department: [
          for (final department in departments) department.toJson(),
        ],
      };

  factory BaseEmployeeProfile.fromJson(JsonMap json) => BaseEmployeeProfile(
        id: json[_BaseEmployeeProfileJsonKeys.id]! as int,
        departmentId: json[_BaseEmployeeProfileJsonKeys.departmentId] != null
            ? int.tryParse(
                json[_BaseEmployeeProfileJsonKeys.departmentId]! as String,
              )
            : null,
        jobTitle: json[_BaseEmployeeProfileJsonKeys.jobTitle]! as String,
        departments: _parseDepartments(
          json[_BaseEmployeeProfileJsonKeys.department],
        ),
      );

  static List<Department> _parseDepartments(dynamic departmentJson) {
    if (departmentJson == null) {
      return [];
    }

    Iterable<JsonMap> departmentMaps;

    if (departmentJson is List) {
      departmentMaps = departmentJson.whereType<JsonMap>();
    } else if (departmentJson is JsonMap) {
      departmentMaps = flattenTree(
        json: departmentJson,
        rootKey: _BaseEmployeeProfileJsonKeys.department,
        childKey: _BaseEmployeeProfileJsonKeys.child,
      ).whereType<JsonMap>();
    } else {
      return [];
    }

    return [for (final map in departmentMaps) Department.fromJson(map)];
  }
}
