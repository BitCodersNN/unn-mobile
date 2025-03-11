class _BlogPostCommentDataJsonBitrixKeys {
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
  final List<int> attachedFiles;
  final String keySigned;

  BlogPostCommentData({
    required this.id,
    required this.authorBitrixId,
    required this.dateTime,
    required this.message,
    required this.keySigned,
    this.attachedFiles = const [],
  });

  factory BlogPostCommentData.fromJson(Map<String, Object?> jsonMap) =>
      BlogPostCommentData(
        id: int.parse(
          jsonMap[_BlogPostCommentDataJsonKeys.id] as String,
        ),
        authorBitrixId: int.parse(
          (jsonMap[_BlogPostCommentDataJsonKeys.author]
              as Map)[_BlogPostCommentDataJsonKeys.id] as String,
        ),
        dateTime:
            jsonMap[_BlogPostCommentDataJsonKeys.time] as String,
        message:
            jsonMap[_BlogPostCommentDataJsonKeys.text] as String,
        keySigned: jsonMap[_BlogPostCommentDataJsonKeys.keysigned]
            as String,
        attachedFiles: (jsonMap[_BlogPostCommentDataJsonKeys.attach]
                as List<dynamic>)
            .map((element) => element.toString().hashCode)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        _BlogPostCommentDataJsonKeys.id: id.toString(),
        _BlogPostCommentDataJsonKeys.author: {
          _BlogPostCommentDataJsonKeys.id:
              authorBitrixId.toString(),
        },
        _BlogPostCommentDataJsonKeys.time: dateTime,
        _BlogPostCommentDataJsonKeys.text: message,
        _BlogPostCommentDataJsonKeys.keysigned: keySigned,
        _BlogPostCommentDataJsonKeys.attach:
            attachedFiles.map((hashCode) => hashCode.toString()).toList(),
      };

  factory BlogPostCommentData.fromJsonLegacy(Map<String, Object?> jsonMap) =>
      BlogPostCommentData(
        id: int.parse(
          jsonMap[_BlogPostCommentDataJsonBitrixKeys.id] as String,
        ),
        authorBitrixId: int.parse(
          jsonMap[_BlogPostCommentDataJsonBitrixKeys.authorId]
              as String,
        ),
        dateTime:
            jsonMap[_BlogPostCommentDataJsonBitrixKeys.dateTime]
                as String,
        message: jsonMap[_BlogPostCommentDataJsonBitrixKeys.message]
            as String,
        keySigned:
            jsonMap[_BlogPostCommentDataJsonBitrixKeys.keySigned]
                as String,
        attachedFiles: (jsonMap[_BlogPostCommentDataJsonBitrixKeys
                .attachedFiles] as List<dynamic>)
            .map((element) => int.parse(element.toString()))
            .toList(),
      );
}
