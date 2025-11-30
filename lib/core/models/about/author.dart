// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';

class _AuthorJsonKeys {
  static const String userId = 'user_id';
  static const String fullname = 'fullname';
  static const String educationGroup = 'education_group';
  static const String avatar = 'avatar';
}

class Author {
  final int? userId;
  final String fullname;
  final String? educationGroup;
  final String avatar;

  String get avatarUrl =>
      '${ProtocolType.https.name}://${Host.gitHub}/${ApiPath.gitRepository}/${ApiPath.authors}/$avatar';

  Author({
    required this.fullname,
    required this.avatar,
    this.userId,
    this.educationGroup,
  });

  factory Author.fromJson(JsonMap json) => Author(
        userId: json[_AuthorJsonKeys.userId] as int?,
        fullname: json[_AuthorJsonKeys.fullname]! as String,
        educationGroup: json[_AuthorJsonKeys.educationGroup] as String?,
        avatar: json[_AuthorJsonKeys.avatar]! as String,
      );

  JsonMap toJson() => {
        _AuthorJsonKeys.userId: userId,
        _AuthorJsonKeys.fullname: fullname,
        _AuthorJsonKeys.educationGroup: educationGroup,
        _AuthorJsonKeys.avatar: avatar,
      };
}
