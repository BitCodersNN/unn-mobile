// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class ForwardInfoJsonKeys {
  static const String forwardId = 'forwardId';
  static const String forwardAuthor = 'forwardAuthor';
}

class ForwardInfo {
  final String forwardChatId;
  final int forwardMessageId;
  final UserShortInfo? forwardAuthor;

  ForwardInfo({
    required this.forwardChatId,
    required this.forwardMessageId,
    required this.forwardAuthor,
  });

  factory ForwardInfo.fromJson(JsonMap jsonMap) => ForwardInfo(
        forwardChatId:
            (jsonMap[ForwardInfoJsonKeys.forwardId] as String).split('/')[0],
        forwardMessageId: int.parse(
          (jsonMap[ForwardInfoJsonKeys.forwardId] as String).split('/')[1],
        ),
        forwardAuthor: jsonMap[ForwardInfoJsonKeys.forwardAuthor] != null
            ? UserShortInfo.fromMessageJson(
                jsonMap[ForwardInfoJsonKeys.forwardAuthor],
              )
            : null,
      );

  JsonMap toJson() => {
        ForwardInfoJsonKeys.forwardId: '$forwardChatId/$forwardMessageId',
        if (forwardAuthor != null)
          ForwardInfoJsonKeys.forwardAuthor: forwardAuthor!.toMessageJson(),
      };
}
