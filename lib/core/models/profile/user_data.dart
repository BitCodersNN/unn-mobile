// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _UserDataJsonKeys {
  static const String id = 'id';
  static const String user = 'user';
  static const String login = 'login';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String sex = 'sex';
  static const String notes = 'notes';
  static const String web = 'web';
  static const String birthdate = 'birthdate';
}

class UserData extends UserShortInfo {
  static Set<String> get jsonKeys => {
        _UserDataJsonKeys.id,
        _UserDataJsonKeys.login,
        _UserDataJsonKeys.email,
        _UserDataJsonKeys.phone,
        _UserDataJsonKeys.sex,
        _UserDataJsonKeys.notes,
        _UserDataJsonKeys.web,
        _UserDataJsonKeys.birthdate,
        ...UserShortInfo.profileJsonKeys,
      };
  final int userId;
  final String? login;
  final String? email;
  final String? phone;
  final String sex;
  final String? notes;
  final String? web;
  final DateTime? birthdate;

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
    required this.web,
    required this.birthdate,
  });

  UserData.withUserShortInfo({
    required UserShortInfo userShortInfo,
    required this.userId,
    required this.sex,
    this.birthdate,
    this.login,
    this.email,
    this.phone,
    this.notes,
    this.web,
  }) : super(
          bitrixId: userShortInfo.bitrixId,
          fullname: userShortInfo.fullname,
          photoSrc: userShortInfo.photoSrc,
        );

  factory UserData.fromJson(JsonMap json) {
    final userJsonMap = (json[_UserDataJsonKeys.user] ?? json) as JsonMap;
    return UserData.withUserShortInfo(
      userShortInfo: UserShortInfo.fromProfileJson(userJsonMap),
      userId: userJsonMap[_UserDataJsonKeys.id]! as int,
      login: userJsonMap[_UserDataJsonKeys.login] as String?,
      email: userJsonMap[_UserDataJsonKeys.email] as String?,
      phone: userJsonMap[_UserDataJsonKeys.phone] as String?,
      sex: userJsonMap[_UserDataJsonKeys.sex]! as String,
      notes: userJsonMap[_UserDataJsonKeys.notes] as String?,
      web: userJsonMap[_UserDataJsonKeys.web] as String?,
      birthdate: DateTime.tryParse(
        userJsonMap[_UserDataJsonKeys.birthdate] as String? ?? '',
      ),
    );
  }

  @override
  JsonMap toJson() => {
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
