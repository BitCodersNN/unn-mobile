// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/employee/base_employee_profile.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _PreviewEmployeeJsonKeys {
  static const String id = 'id';
  static const String profiles = 'profiles';
}

class PreviewEmployee extends UserShortInfo {
  final int userId;
  final List<BaeEmployeeProfile> profiles;

  PreviewEmployee({
    required this.userId,
    super.bitrixId,
    required super.fullname,
    required super.photoSrc,
    required this.profiles,
  });

  PreviewEmployee.withUserShortInfo({
    required this.userId,
    required UserShortInfo userShortInfo,
    required this.profiles,
  }) : super(
          bitrixId: userShortInfo.bitrixId,
          fullname: userShortInfo.fullname,
          photoSrc: userShortInfo.photoSrc,
        );

  factory PreviewEmployee.fromJson(Map<String, Object?> json) =>
      PreviewEmployee.withUserShortInfo(
        userId: json[_PreviewEmployeeJsonKeys.id] as int,
        userShortInfo: UserShortInfo.fromProfileJson(json),
        profiles: (json[_PreviewEmployeeJsonKeys.profiles] as List)
            .map(
              (item) =>
                  BaeEmployeeProfile.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );
}
