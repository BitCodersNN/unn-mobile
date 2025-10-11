// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/employee/base_employee_profile.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _EmployeeProfileJsonKeys {
  static const String jobType = 'job_type';
  static const String manager = 'manager';
}

class EmployeeProfile {
  final BaseEmployeeProfile previewEmployeeProfile;
  final String jobType;
  final UserShortInfo? manager;

  EmployeeProfile({
    required this.previewEmployeeProfile,
    required this.jobType,
    this.manager,
  });

  Map<String, dynamic> toJson() => {
        ...previewEmployeeProfile.toJson(),
        _EmployeeProfileJsonKeys.jobType: jobType,
        _EmployeeProfileJsonKeys.manager: manager?.toProfileJson(),
      };

  factory EmployeeProfile.fromJson(Map<String, Object?> json) =>
      EmployeeProfile(
        previewEmployeeProfile: BaseEmployeeProfile.fromJson(json),
        jobType: json[_EmployeeProfileJsonKeys.jobType] as String,
        manager: json[_EmployeeProfileJsonKeys.manager] != null
            ? UserShortInfo.fromProfileJson(
                json[_EmployeeProfileJsonKeys.manager] as Map<String, dynamic>,
              )
            : null,
      );
}
