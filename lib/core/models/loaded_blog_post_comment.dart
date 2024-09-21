import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/rating_list.dart';

class LoadedBlogPostComment {
  final BlogPostComment comment;
  final RatingList? ratingList;

  LoadedBlogPostComment({
    required this.comment,
    required this.ratingList,
  });
}
