class _KeysForBlogPostCommentDataJsonConverterLegacy {
  static const String id = 'id';
  static const String dateTime = 'dateTime';
  static const String authorId = 'authorId';
  static const String message = 'message';
  static const String keySigned = 'keySigned';
  static const String attachedFiles = 'attachedFiles';
}

class _KeysForBlogPostCommentDataJsonConverter {
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
          jsonMap[_KeysForBlogPostCommentDataJsonConverter.id] as String,
        ),
        authorBitrixId: int.parse(
          (jsonMap[_KeysForBlogPostCommentDataJsonConverter.author]
              as Map)[_KeysForBlogPostCommentDataJsonConverter.id] as String,
        ),
        dateTime:
            jsonMap[_KeysForBlogPostCommentDataJsonConverter.time] as String,
        message:
            jsonMap[_KeysForBlogPostCommentDataJsonConverter.text] as String,
        keySigned: jsonMap[_KeysForBlogPostCommentDataJsonConverter.keysigned]
            as String,
        attachedFiles: (jsonMap[_KeysForBlogPostCommentDataJsonConverter.attach]
                as List<dynamic>)
            .map((element) => element.toString().hashCode)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        _KeysForBlogPostCommentDataJsonConverter.id: id.toString(),
        _KeysForBlogPostCommentDataJsonConverter.author: {
          _KeysForBlogPostCommentDataJsonConverter.id:
              authorBitrixId.toString(),
        },
        _KeysForBlogPostCommentDataJsonConverter.time: dateTime,
        _KeysForBlogPostCommentDataJsonConverter.text: message,
        _KeysForBlogPostCommentDataJsonConverter.keysigned: keySigned,
        _KeysForBlogPostCommentDataJsonConverter.attach:
            attachedFiles.map((hashCode) => hashCode.toString()).toList(),
      };

  factory BlogPostCommentData.fromJsonLegacy(Map<String, Object?> jsonMap) =>
      BlogPostCommentData(
        id: int.parse(
          jsonMap[_KeysForBlogPostCommentDataJsonConverterLegacy.id] as String,
        ),
        authorBitrixId: int.parse(
          jsonMap[_KeysForBlogPostCommentDataJsonConverterLegacy.authorId]
              as String,
        ),
        dateTime:
            jsonMap[_KeysForBlogPostCommentDataJsonConverterLegacy.dateTime]
                as String,
        message: jsonMap[_KeysForBlogPostCommentDataJsonConverterLegacy.message]
            as String,
        keySigned:
            jsonMap[_KeysForBlogPostCommentDataJsonConverterLegacy.keySigned]
                as String,
        attachedFiles: (jsonMap[_KeysForBlogPostCommentDataJsonConverterLegacy
                .attachedFiles] as List<dynamic>)
            .map((element) => int.parse(element.toString()))
            .toList(),
      );
}
