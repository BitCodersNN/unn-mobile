class BlogPostComment {
  final int id;
  final int authorId;
  final String authorName;
  final String dateTime;
  final String message;
  final List<int> attachedFiles;

  BlogPostComment(
      {required this.id,
      required this.authorId,
      required this.authorName,
      required this.dateTime,
      required this.message,
      this.attachedFiles = const []});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "dateTime": dateTime,
      "authorId": authorId,
      "authorName": authorName,
      "message": message,
      "attachedFiles": attachedFiles,
    };
  }
}
