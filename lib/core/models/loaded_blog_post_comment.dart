import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';

class LoadedBlogPostComment {
  final BlogPostComment comment;
  final UserData? author;
  final List<FileData> files;
  final RatingList? ratingList;

  LoadedBlogPostComment({
    required this.comment,
    required this.author,
    required this.files,
    required this.ratingList,
  });
}
