import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message_status.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';

class MessageJsonKeys {
  static const String ratingList = 'ratingList';
  static const String messageStatus = 'messageStatus';
  static const String viewedByOthers = 'viewedByOthers';
  static const String notify = 'notify';
}

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
          files: messageShortInfo.files,
          text: messageShortInfo.text,
          uuid: messageShortInfo.uuid,
        );

  factory Message.fromJson(Map<String, dynamic> jsonMap) => Message(
        messageShortInfo: MessageShortInfo.fromJson(jsonMap),
        ratingList: jsonMap[MessageJsonKeys.ratingList],
        messageStatus: jsonMap[MessageJsonKeys.messageStatus],
        viewedByOthers: jsonMap[MessageJsonKeys.viewedByOthers],
        notify: jsonMap[MessageJsonKeys.notify],
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        MessageJsonKeys.ratingList: ratingList,
        MessageJsonKeys.messageStatus: messageStatus,
        MessageJsonKeys.viewedByOthers: viewedByOthers,
        MessageJsonKeys.notify: notify,
      };
}
