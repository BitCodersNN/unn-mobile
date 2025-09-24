// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/tree_flattener.dart';
import 'package:unn_mobile/core/models/profile/employee/department.dart';

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
        id: json['id'] as int,
        departmentId: int.tryParse(json['department_id'] as String),
        jobTitle: json['job_title'] as String,
        departments: (json['department'] as List)
            .map((item) => Department.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  factory BaeEmployeeProfile.fromProfileJson(Map<String, Object?> json) =>
      BaeEmployeeProfile(
        id: json['id'] as int,
        departmentId: int.tryParse(json['department_id'] as String),
        jobTitle: json['job_title'] as String,
        departments: (flattenTree(
          json: json['department'] as Map<String, dynamic>,
          rootKey: 'department',
          childKey: 'child',
        )).map((item) => Department.fromJson(item)).toList(),
      );
}
