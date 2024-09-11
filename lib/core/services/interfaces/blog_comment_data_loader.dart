import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/loaded_blog_post_comment.dart';

abstract interface class BlogCommentDataLoader {
  Future<LoadedBlogPostComment> load(BlogPostComment comment);
}
