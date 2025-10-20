// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/profile/employee/base_employee_profile.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _PreviewEmployeeJsonKeys {
  static const String id = 'id';
  static const String profiles = 'profiles';
}

class PreviewEmployee extends UserShortInfo {
  final int userId;
  final List<BaseEmployeeProfile> profiles;

  PreviewEmployee({
    required this.userId,
    required super.fullname,
    required super.photoSrc,
    required this.profiles,
    super.bitrixId,
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

  factory PreviewEmployee.fromJson(JsonMap json) =>
      PreviewEmployee.withUserShortInfo(
        userId: json[_PreviewEmployeeJsonKeys.id] as int,
        userShortInfo: UserShortInfo.fromProfileJson(json),
        profiles: (json[_PreviewEmployeeJsonKeys.profiles] as List)
            .map(
              (item) => BaseEmployeeProfile.fromJson(item as JsonMap),
            )
            .toList(),
      );

  @override
  JsonMap toJson() => {
        ...super.toProfileJson(),
        _PreviewEmployeeJsonKeys.id: userId,
        _PreviewEmployeeJsonKeys.profiles:
            profiles.map((profile) => profile.toJson()).toList(),
      };
}
