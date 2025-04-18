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

  factory ForwardInfo.fromJson(Map<String, dynamic> jsonMap) => ForwardInfo(
        forwardChatId: jsonMap[ForwardInfoJsonKeys.forwardId].split('/')[0],
        forwardMessageId:
            int.parse(jsonMap[ForwardInfoJsonKeys.forwardId].split('/')[1]),
        forwardAuthor: jsonMap[ForwardInfoJsonKeys.forwardAuthor] != null
            ? UserShortInfo.fromMessageJson(
                jsonMap[ForwardInfoJsonKeys.forwardAuthor],
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        ForwardInfoJsonKeys.forwardId: '$forwardChatId/$forwardMessageId',
        if (forwardAuthor != null)
          ForwardInfoJsonKeys.forwardAuthor: forwardAuthor!.toMessageJson(),
      };
}
