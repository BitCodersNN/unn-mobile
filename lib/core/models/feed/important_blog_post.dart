import 'package:unn_mobile/core/models/feed/blog_post.dart';

class ImportantBlogPost extends BlogPost {
  final bool isRead;
  final int readCount;

  ImportantBlogPost({
    required super.data,
    required super.ratingList,
    required super.userShortInfo,
    required super.attachFiles,
    required super.comments,
    required super.commentCount,
    required this.isRead,
    required this.readCount,
  });
}
