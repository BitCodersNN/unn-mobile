// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_profile.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';

class _EmployeeDataJsonKeys {
  static const String profiles = 'profiles';
  static const String syncId = 'sync_id';
}

class EmployeeData extends UserData {
  static Set<String> get jsonKeys => {
        _EmployeeDataJsonKeys.syncId,
        _EmployeeDataJsonKeys.profiles,
        ...UserData.jsonKeys,
      };

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
    required super.web,
    required super.birthdate,
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
          web: userData.web,
          birthdate: userData.birthdate,
        );

  @override
  JsonMap toJson() => {
        ...super.toJson(),
        _EmployeeDataJsonKeys.syncId: syncId,
        _EmployeeDataJsonKeys.profiles: [
          for (final profile in profiles) profile.toJson(),
        ],
      };

  factory EmployeeData.fromJson(JsonMap json) => EmployeeData.withUserData(
        userData: UserData.fromJson(json),
        syncId: json[_EmployeeDataJsonKeys.syncId]! as String,
        profiles: [
          for (final item in json[_EmployeeDataJsonKeys.profiles]! as List)
            EmployeeProfile.fromJson(item as JsonMap),
        ],
      );

  factory EmployeeData.fromCurrentProfileJson(JsonMap json) =>
      EmployeeData.withUserData(
        userData: UserData.fromJson(json),
        syncId: json[_EmployeeDataJsonKeys.syncId]! as String,
        profiles: [EmployeeProfile.fromJson(json)],
      );
}
