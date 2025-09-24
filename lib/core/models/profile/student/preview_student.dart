// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/student/base_edu_info.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class PreviewStudent extends UserShortInfo {
  final int userId;
  final BaseEduInfo baseEduInfo;

  PreviewStudent({
    super.bitrixId,
    required super.fullname,
    required super.photoSrc,
    required this.userId,
    required this.baseEduInfo,
  });

  PreviewStudent.withUserShortInfo({
    required UserShortInfo userShortInfo,
    required this.userId,
    required this.baseEduInfo,
  }) : super(
          bitrixId: userShortInfo.bitrixId,
          fullname: userShortInfo.fullname,
          photoSrc: userShortInfo.photoSrc,
        );

  factory PreviewStudent.fromJson(Map<String, Object?> json) =>
      PreviewStudent.withUserShortInfo(
        userShortInfo: UserShortInfo.fromProfileJson(json),
        userId: json['user_id'] as int,
        baseEduInfo: BaseEduInfo.previewStudentfromJson(json),
      );
}
