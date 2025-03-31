import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class Message {
  final int messageId;
  final UserShortInfo? author;
  final RatingList? ratingList;
  final FileData? file;
  // Ещё надо хранить систумную информацию
  final String text;
  final String? uuid;

  Message({
    required this.messageId,
    required this.author,
    required this.ratingList,
    required this.file,
    required this.text,
    required this.uuid,
  });

  factory Message.fromJson(Map<String, dynamic> jsonMap) => Message(
        messageId: jsonMap['id'] as int,
        author: jsonMap['author'] != null
            ? UserShortInfo.fromMessageJson(jsonMap['author'])
            : null,
        ratingList: jsonMap['ratingList'],
        file: jsonMap['file'],
        text: jsonMap['text'] as String,
        uuid: jsonMap['uuid'] as String?,
      );
}
