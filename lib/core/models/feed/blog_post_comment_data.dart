import 'package:unn_mobile/core/misc/extract_and_clean_images.dart';

class _BlogPostCommentDataBitrixJsonKeys {
  static const String id = 'id';
  static const String dateTime = 'dateTime';
  static const String authorId = 'authorId';
  static const String message = 'message';
  static const String keySigned = 'keySigned';
  static const String attachedFiles = 'attachedFiles';
}

class _BlogPostCommentDataJsonKeys {
  static const String id = 'id';
  static const String author = 'author';
  static const String time = 'time';
  static const String text = 'text';
  static const String keysigned = 'keysigned';
  static const String attach = 'attach';
}

class BlogPostCommentData {
  final int id;
  final int authorBitrixId;
  final String dateTime;
  final String message;
  final List<String>? imageUrls;
  final List<int> attachedFiles;
  final String keySigned;

  BlogPostCommentData({
    required this.id,
    required this.authorBitrixId,
    required this.dateTime,
    required this.message,
    this.imageUrls,
    required this.keySigned,
    this.attachedFiles = const [],
  });

  factory BlogPostCommentData.fromJson(Map<String, Object?> jsonMap) {
    final text = jsonMap[_BlogPostCommentDataJsonKeys.text] as String;
    final result = extractAndCleanImages(text);
    return BlogPostCommentData(
      id: int.parse(
        jsonMap[_BlogPostCommentDataJsonKeys.id] as String,
      ),
      authorBitrixId: int.parse(
        (jsonMap[_BlogPostCommentDataJsonKeys.author]
            as Map)[_BlogPostCommentDataJsonKeys.id] as String,
      ),
      dateTime: jsonMap[_BlogPostCommentDataJsonKeys.time] as String,
      message: result[ExtractAndCleanImagesMapKey.cleanedText],
      imageUrls: result[ExtractAndCleanImagesMapKey.imageUrls],
      keySigned: jsonMap[_BlogPostCommentDataJsonKeys.keysigned] as String,
      attachedFiles:
          (jsonMap[_BlogPostCommentDataJsonKeys.attach] as List<dynamic>)
              .map((element) => element.toString().hashCode)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        _BlogPostCommentDataJsonKeys.id: id.toString(),
        _BlogPostCommentDataJsonKeys.author: {
          _BlogPostCommentDataJsonKeys.id: authorBitrixId.toString(),
        },
        _BlogPostCommentDataJsonKeys.time: dateTime,
        _BlogPostCommentDataJsonKeys.text: restoreMessage(message, imageUrls),
        _BlogPostCommentDataJsonKeys.keysigned: keySigned,
        _BlogPostCommentDataJsonKeys.attach:
            attachedFiles.map((hashCode) => hashCode.toString()).toList(),
      };

  factory BlogPostCommentData.fromBitrixJson(Map<String, Object?> jsonMap) =>
      BlogPostCommentData(
        id: int.parse(
          jsonMap[_BlogPostCommentDataBitrixJsonKeys.id] as String,
        ),
        authorBitrixId: int.parse(
          jsonMap[_BlogPostCommentDataBitrixJsonKeys.authorId] as String,
        ),
        dateTime:
            jsonMap[_BlogPostCommentDataBitrixJsonKeys.dateTime] as String,
        message: jsonMap[_BlogPostCommentDataBitrixJsonKeys.message] as String,
        keySigned:
            jsonMap[_BlogPostCommentDataBitrixJsonKeys.keySigned] as String,
        attachedFiles:
            (jsonMap[_BlogPostCommentDataBitrixJsonKeys.attachedFiles]
                    as List<dynamic>)
                .map((element) => int.parse(element.toString()))
                .toList(),
      );
}
