import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/loaded_blog_post_comment.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/blog_comment_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';

class BlogCommentDataLoaderImpl implements BlogCommentDataLoader {
  final GettingRatingList _gettingRatingList;

  BlogCommentDataLoaderImpl(
    this._gettingRatingList,
  );

  @override
  Future<LoadedBlogPostComment> load(BlogPostComment comment) async {
    final ratingList = await _gettingRatingList.getRatingList(
      voteKeySigned: comment.keySigned,
    );

    final blogPostCommentWithLoadedInfo = LoadedBlogPostComment(
      comment: comment,
      ratingList: ratingList ?? RatingList(),
    );

    return blogPostCommentWithLoadedInfo;
  }
}
