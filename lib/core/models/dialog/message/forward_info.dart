import 'package:unn_mobile/core/models/profile/user_short_info.dart';

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
        forwardChatId: jsonMap['forwardId'].split('/')[0],
        forwardMessageId: int.parse(jsonMap['forwardId'].split('/')[1]),
        forwardAuthor: jsonMap['forwardAuthor'] != null
            ? UserShortInfo.fromMessageJson(jsonMap['forwardAuthor'])
            : null,
      );
}
