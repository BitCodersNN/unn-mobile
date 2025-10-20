// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/profile/student/base_edu_info.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';

class _StudentDataJsonKeys {
  static const String eduStatus = 'edu_status';
  static const String eduYear = 'edu_year';
}

class StudentData extends UserData {
  final BaseEduInfo baseEduInfo;
  final String eduStatus;
  final int eduYear;

  StudentData({
    required super.bitrixId,
    required super.fullname,
    required super.photoSrc,
    required super.userId,
    required super.login,
    required super.email,
    required super.phone,
    required super.sex,
    required super.notes,
    required this.baseEduInfo,
    required this.eduStatus,
    required this.eduYear,
  });

  StudentData.withUserData({
    required UserData userData,
    required this.baseEduInfo,
    required this.eduStatus,
    required this.eduYear,
  }) : super(
          userId: userData.userId,
          bitrixId: userData.bitrixId,
          login: userData.login,
          fullname: userData.fullname,
          email: userData.email,
          phone: userData.phone,
          sex: userData.sex,
          photoSrc: userData.photoSrc,
          notes: userData.notes,
        );

  factory StudentData.fromJson(JsonMap json) => StudentData.withUserData(
        baseEduInfo: BaseEduInfo.fromJson(json),
        userData: UserData.fromJson(json),
        eduStatus: json[_StudentDataJsonKeys.eduStatus] as String,
        eduYear: json[_StudentDataJsonKeys.eduYear] as int,
      );

  @override
  JsonMap toJson() => {
        ...super.toJson(),
        ...baseEduInfo.toJson(),
        _StudentDataJsonKeys.eduStatus: eduStatus,
        _StudentDataJsonKeys.eduYear: eduYear,
      };
}
