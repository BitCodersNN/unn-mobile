import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/dialog/message/message_short_info.dart';
import 'package:unn_mobile/core/models/dialog/message/enum/message_state.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';

class MessageJsonKeys {
  static const String ratingList = 'ratingList';
  static const String messageStatus = 'messageStatus';
  static const String files = 'files';
  static const String viewedByOthers = 'viewedByOthers';
  static const String notify = 'notify';
}

class Message extends MessageShortInfo {
  final RatingList? ratingList;
  final MessageState messageStatus;
  final List<FileData> files;
  final bool viewedByOthers;
  final bool notify;

  Message({
    required MessageShortInfo messageShortInfo,
    required this.ratingList,
    required this.messageStatus,
    required this.files,
    required this.viewedByOthers,
    required this.notify,
  }) : super(
          messageId: messageShortInfo.messageId,
          author: messageShortInfo.author,
          text: messageShortInfo.text,
          uuid: messageShortInfo.uuid,
          dateTime: messageShortInfo.dateTime,
        );

  factory Message.fromJson(Map<String, dynamic> jsonMap) {
    final List<FileData> files = [];
    for (final file in jsonMap[MessageJsonKeys.files]) {
      files.add(
        FileData.fromMessageJson(file),
      );
    }

    return Message(
      messageShortInfo: MessageShortInfo.fromJson(jsonMap),
      ratingList: jsonMap[MessageJsonKeys.ratingList],
      messageStatus: jsonMap[MessageJsonKeys.messageStatus],
      files: files,
      viewedByOthers: jsonMap[MessageJsonKeys.viewedByOthers],
      notify: jsonMap[MessageJsonKeys.notify],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> filesJson = [];
    for (final file in files) {
      filesJson.add(file.toMessageJson());
    }

    return {
      ...super.toJson(),
      MessageJsonKeys.ratingList: ratingList,
      MessageJsonKeys.messageStatus: messageStatus,
      MessageJsonKeys.files: filesJson,
      MessageJsonKeys.viewedByOthers: viewedByOthers,
      MessageJsonKeys.notify: notify,
    };
  }
}
