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
}
