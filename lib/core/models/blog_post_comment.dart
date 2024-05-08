class _KeysForBlogPostCommentJsonConverter {
  static const String id = 'id';
  static const String dateTime = 'dateTime';
  static const String authorId = 'authorId';
  static const String authorName = 'authorName';
  static const String message = 'message';
  static const String keySigned = 'keySigned';
  static const String attachedFiles = 'attachedFiles';
}

class BlogPostComment {
  final int id;
  final int bitrixID;
  final String authorName;
  final String dateTime;
  final String message;
  final List<int> attachedFiles;
  final String keySigned;

  BlogPostComment({
    required this.id,
    required this.bitrixID,
    required this.authorName,
    required this.dateTime,
    required this.message,
    required this.keySigned,
    this.attachedFiles = const [],
  });

  factory BlogPostComment.fromJson(Map<String, Object?> jsonMap) =>
      BlogPostComment(
        id: int.parse(
          jsonMap[_KeysForBlogPostCommentJsonConverter.id] as String,
        ),
        bitrixID: int.parse(
          jsonMap[_KeysForBlogPostCommentJsonConverter.authorId] as String,
        ),
        authorName:
            jsonMap[_KeysForBlogPostCommentJsonConverter.authorName] as String,
        dateTime:
            jsonMap[_KeysForBlogPostCommentJsonConverter.dateTime] as String,
        message:
            jsonMap[_KeysForBlogPostCommentJsonConverter.message] as String,
        keySigned:
            jsonMap[_KeysForBlogPostCommentJsonConverter.keySigned] as String,
        attachedFiles:
            (jsonMap[_KeysForBlogPostCommentJsonConverter.attachedFiles]
                    as List<dynamic>)
                .map((element) => int.parse(element.toString()))
                .toList(),
      );

  Map<String, dynamic> toJson() {
    return {
      _KeysForBlogPostCommentJsonConverter.id: id,
      _KeysForBlogPostCommentJsonConverter.dateTime: dateTime,
      _KeysForBlogPostCommentJsonConverter.authorId: bitrixID,
      _KeysForBlogPostCommentJsonConverter.authorName: authorName,
      _KeysForBlogPostCommentJsonConverter.message: message,
      _KeysForBlogPostCommentJsonConverter.keySigned: keySigned,
      _KeysForBlogPostCommentJsonConverter.attachedFiles: attachedFiles,
    };
  }
}
