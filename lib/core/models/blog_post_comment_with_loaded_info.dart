import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';

class BlogPostCommentWithLoadedInfo {
  final BlogPostComment comment;
  final UserData author;
  final List<FileData> files;

  BlogPostCommentWithLoadedInfo({
    required this.comment,
    required this.author,
    required this.files,
  });
}
