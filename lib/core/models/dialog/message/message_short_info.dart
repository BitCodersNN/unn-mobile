import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class MessageShortInfo {
  final int messageId;
  final UserShortInfo? author;
  final List<FileData> file;
  final String text;
  final String? uuid;

  MessageShortInfo({
    required this.messageId,
    required this.author,
    required this.file,
    required this.text,
    required this.uuid,
  });

  factory MessageShortInfo.fromJson(Map<String, dynamic> jsonMap) {
    final List<FileData> files = [];
    for (final file in jsonMap['files']) {
      files.add(
        FileData.fromMessageJson(file),
      );
    }

    return MessageShortInfo(
      messageId: jsonMap['id'],
      author: jsonMap['author'] != null
          ? UserShortInfo.fromMessageJson(jsonMap['author'])
          : null,
      file: files,
      text: jsonMap['text'],
      uuid: jsonMap['uuid'],
    );
  }
}
