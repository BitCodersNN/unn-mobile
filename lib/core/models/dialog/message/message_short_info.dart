import 'package:unn_mobile/core/misc/json/json_key_format.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class MessageShortInfoJsonKeys {
  static const String files = 'files';
  static const String id = 'id';
  static const String author = 'author';
  static const String text = 'text';
  static const String uuid = 'uuid';
}

class MessageShortInfo {
  final int messageId;
  final UserShortInfo? author;
  final List<FileData> files;
  final String text;
  final String? uuid;

  MessageShortInfo({
    required this.messageId,
    required this.author,
    required this.files,
    required this.text,
    required this.uuid,
  });

  factory MessageShortInfo.fromJson(Map<String, dynamic> jsonMap) {
    final List<FileData> files = [];
    for (final file in jsonMap[MessageShortInfoJsonKeys.files]) {
      files.add(
        FileData.fromMessageJson(file),
      );
    }

    return MessageShortInfo(
      messageId: jsonMap[MessageShortInfoJsonKeys.id],
      author: jsonMap[MessageShortInfoJsonKeys.author] != null
          ? UserShortInfo.fromMessageJson(
              jsonMap[MessageShortInfoJsonKeys.author],
            )
          : null,
      files: files,
      text: jsonMap[MessageShortInfoJsonKeys.text],
      uuid: jsonMap[MessageShortInfoJsonKeys.uuid],
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> filesJson = [];
    for (final file in files) {
      filesJson.add(file.toJson(format: JsonKeyFormat.message));
    }

    return {
      MessageShortInfoJsonKeys.id: messageId,
      if (author != null)
        MessageShortInfoJsonKeys.author:
            author!.toJson(format: JsonKeyFormat.message),
      MessageShortInfoJsonKeys.files: filesJson,
      MessageShortInfoJsonKeys.text: text,
      MessageShortInfoJsonKeys.uuid: uuid,
    };
  }
}
