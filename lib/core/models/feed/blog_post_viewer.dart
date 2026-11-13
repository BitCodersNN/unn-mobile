// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _JsonKeys {
  static const String viewedAt = 'DATE_VIEW';
}

class BlogPostViewer extends UserShortInfo {
  final DateTime viewedAt;

  new({required this.viewedAt, super.bitrixId, super.fullname, super.photoSrc});

  @override
  JsonMap toJson() => {
    ...super.toBlogPostJson(),
    _JsonKeys.viewedAt: viewedAt.format(DatePattern.ddmmyyyyhhmmss),
  };

  factory BlogPostViewer.fromJson(JsonMap jsonMap) {
    final userShortInfo = UserShortInfo.fromJsonImportantBlogPost(jsonMap);

    return BlogPostViewer(
      viewedAt: DateTimeParser.parse(
        jsonMap[_JsonKeys.viewedAt]! as String,
        DatePattern.ddmmyyyyhhmmss,
      ),
      bitrixId: userShortInfo.bitrixId,
      fullname: userShortInfo.fullname,
      photoSrc: userShortInfo.photoSrc,
    );
  }
}
