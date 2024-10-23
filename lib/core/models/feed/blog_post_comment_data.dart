class _KeysForBlogPostCommentDataJsonConverter {
  static const String id = 'id';
  static const String dateTime = 'dateTime';
  static const String authorId = 'authorId';
  static const String message = 'message';
  static const String keySigned = 'keySigned';
  static const String attachedFiles = 'attachedFiles';
}

class _KeysForBlogPostCommentDataJsonConverterPortal2 {
  static const String id = 'id';
  static const String author = 'author';
  static const String time = 'time';
  static const String text = 'text';
  static const String keysigned = 'keysigned';
  static const String attach = 'attach';
}

class BlogPostCommentData {
  final int id;
  final int bitrixID;
  final String dateTime;
  final String message;
  final List<int> attachedFiles;
  final String keySigned;

  BlogPostCommentData({
    required this.id,
    required this.bitrixID,
    required this.dateTime,
    required this.message,
    required this.keySigned,
    this.attachedFiles = const [],
  });

  factory BlogPostCommentData.fromJson(Map<String, Object?> jsonMap) =>
      BlogPostCommentData(
        id: int.parse(
          jsonMap[_KeysForBlogPostCommentDataJsonConverter.id] as String,
        ),
        bitrixID: int.parse(
          jsonMap[_KeysForBlogPostCommentDataJsonConverter.authorId] as String,
        ),
        dateTime:
            jsonMap[_KeysForBlogPostCommentDataJsonConverter.dateTime] as String,
        message:
            jsonMap[_KeysForBlogPostCommentDataJsonConverter.message] as String,
        keySigned:
            jsonMap[_KeysForBlogPostCommentDataJsonConverter.keySigned] as String,
        attachedFiles:
            (jsonMap[_KeysForBlogPostCommentDataJsonConverter.attachedFiles]
                    as List<dynamic>)
                .map((element) => int.parse(element.toString()))
                .toList(),
      );

  factory BlogPostCommentData.fromJsonPortal2(Map<String, Object?> jsonMap) =>
      BlogPostCommentData(
        id: int.parse(
          jsonMap[_KeysForBlogPostCommentDataJsonConverterPortal2.id] as String,
        ),
        bitrixID: int.parse(
          (jsonMap[_KeysForBlogPostCommentDataJsonConverterPortal2.author]
              as Map)[_KeysForBlogPostCommentDataJsonConverterPortal2.id] as String,
        ),
        dateTime:
            jsonMap[_KeysForBlogPostCommentDataJsonConverterPortal2.time] as String,
        message:
            jsonMap[_KeysForBlogPostCommentDataJsonConverterPortal2.text] as String,
        keySigned:
            jsonMap[_KeysForBlogPostCommentDataJsonConverterPortal2.keysigned]
                as String,
        attachedFiles:
            (jsonMap[_KeysForBlogPostCommentDataJsonConverterPortal2.attach]
                    as List<dynamic>)
                .map((element) => element.toString().hashCode)
                .toList(),
      );

  Map<String, dynamic> toJson() {
    return {
      _KeysForBlogPostCommentDataJsonConverter.id: id,
      _KeysForBlogPostCommentDataJsonConverter.dateTime: dateTime,
      _KeysForBlogPostCommentDataJsonConverter.authorId: bitrixID,
      _KeysForBlogPostCommentDataJsonConverter.message: message,
      _KeysForBlogPostCommentDataJsonConverter.keySigned: keySigned,
      _KeysForBlogPostCommentDataJsonConverter.attachedFiles: attachedFiles,
    };
  }
}
