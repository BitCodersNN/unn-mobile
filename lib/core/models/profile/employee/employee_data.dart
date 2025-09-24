// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/employee/employee_profile.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';

class EmployeeData extends UserData {
  final String syncId;
  final List<EmployeeProfile> profiles;

  EmployeeData({
    required super.bitrixId,
    required super.fullname,
    required super.photoSrc,
    required super.userId,
    required super.login,
    required super.email,
    required super.phone,
    required super.sex,
    required super.notes,
    required this.syncId,
    required this.profiles,
  });

  EmployeeData.withUserData({
    required UserData userData,
    required this.syncId,
    required this.profiles,
  }) : super(
          bitrixId: userData.bitrixId,
          login: userData.login,
          fullname: userData.fullname,
          userId: userData.userId,
          email: userData.email,
          phone: userData.phone,
          sex: userData.sex,
          photoSrc: userData.photoSrc,
          notes: userData.notes,
        );

  factory EmployeeData.fromJson(Map<String, Object?> json) =>
      EmployeeData.withUserData(
        userData:
            UserData.fromJson((json['profiles'] as List)[0]['user'] ?? json),
        syncId: json['sync_id'] as String,
        profiles: (json['profiles'] as List)
            .map(
              (item) => EmployeeProfile.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );

  factory EmployeeData.fromCurrentProfileJson(Map<String, Object?> json) =>
      EmployeeData.withUserData(
        userData: UserData.fromJson(json),
        syncId: json['sync_id'] as String,
        profiles: [EmployeeProfile.fromJson(json)],
      );
}
