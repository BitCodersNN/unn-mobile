import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message_status.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';

class Message extends MessageShortInfo {
  final RatingList? ratingList;
  final MessageStatus messageStatus;
  final bool viewedByOthers;
  final bool notify;

  Message({
    required MessageShortInfo messageShortInfo,
    required this.ratingList,
    required this.messageStatus,
    required this.viewedByOthers,
    required this.notify,
  }) : super(
          messageId: messageShortInfo.messageId,
          author: messageShortInfo.author,
          file: messageShortInfo.file,
          text: messageShortInfo.text,
          uuid: messageShortInfo.uuid,
        );

  factory Message.fromJson(Map<String, dynamic> jsonMap) {
    return Message(
      messageShortInfo: MessageShortInfo.fromJson(jsonMap),
      ratingList: jsonMap['ratingList'],
      messageStatus: jsonMap['messageStatus'],
      viewedByOthers: jsonMap['viewedByOthers'],
      notify: jsonMap['notify'],
    );
  }
}
