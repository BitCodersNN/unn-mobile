// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _UserDataJsonKeys {
  static const String id = 'id';
  static const String user = 'user';
  static const String login = 'login';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String sex = 'sex';
  static const String notes = 'notes';
}

class UserData extends UserShortInfo {
  final int userId;
  final String? login;
  final String? email;
  final String? phone;
  final String sex;
  final String? notes;

  UserData({
    required super.bitrixId,
    required super.fullname,
    required super.photoSrc,
    required this.userId,
    required this.login,
    required this.email,
    required this.phone,
    required this.sex,
    required this.notes,
  });

  UserData.withUserShortInfo({
    required UserShortInfo userShortInfo,
    required this.userId,
    this.login,
    this.email,
    this.phone,
    required this.sex,
    this.notes,
  }) : super(
          bitrixId: userShortInfo.bitrixId,
          fullname: userShortInfo.fullname,
          photoSrc: userShortInfo.photoSrc,
        );

  factory UserData.fromJson(Map<String, Object?> json) {
    final userJsonMap =
        (json[_UserDataJsonKeys.user] ?? json) as Map<String, Object?>;
    return UserData.withUserShortInfo(
      userShortInfo: UserShortInfo.fromProfileJson(userJsonMap),
      userId: userJsonMap[_UserDataJsonKeys.id] as int,
      login: userJsonMap[_UserDataJsonKeys.login] as String?,
      email: userJsonMap[_UserDataJsonKeys.email] as String?,
      phone: userJsonMap[_UserDataJsonKeys.phone] as String?,
      sex: userJsonMap[_UserDataJsonKeys.sex] as String,
      notes: userJsonMap[_UserDataJsonKeys.notes] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        _UserDataJsonKeys.user: {
          ...super.toProfileJson(),
          _UserDataJsonKeys.id: userId,
          _UserDataJsonKeys.login: login,
          _UserDataJsonKeys.email: email,
          _UserDataJsonKeys.phone: phone,
          _UserDataJsonKeys.sex: sex,
          _UserDataJsonKeys.notes: notes,
        },
      };
}
