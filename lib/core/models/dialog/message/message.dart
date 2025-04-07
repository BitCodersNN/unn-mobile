import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/dialog/message/message_status.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class Message {
  final int messageId;
  final UserShortInfo? author;
  final RatingList? ratingList;
  final List<FileData> file;
  final String text;
  final String? uuid;
  final MessageStatus messageStatus;
  final bool viewedByOthers;
  final bool notify;

  Message({
    required this.messageId,
    required this.author,
    required this.ratingList,
    required this.file,
    required this.text,
    required this.uuid,
    required this.messageStatus,
    required this.viewedByOthers,
    required this.notify,
  });

  factory Message.fromJson(Map<String, dynamic> jsonMap) {
    final List<FileData> files = [];
    for (final file in jsonMap['files']) {
      files.add(
        FileData.fromMessageJson(file),
      );
    }

    return Message(
      messageId: jsonMap['id'],
      author: jsonMap['author'] != null
          ? UserShortInfo.fromMessageJson(jsonMap['author'])
          : null,
      ratingList: jsonMap['ratingList'],
      file: files,
      text: jsonMap['text'],
      uuid: jsonMap['uuid'],
      messageStatus: jsonMap['messageStatus'],
      viewedByOthers: jsonMap['viewedByOthers'],
      notify: jsonMap['notify'],
    );
  }
}
