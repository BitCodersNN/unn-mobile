import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/loaded_blog_post_comment.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/blog_comment_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';

class BlogCommentDataLoaderImpl implements BlogCommentDataLoader {
  final LRUCacheUserData _usersCache;
  final GettingProfile _gettingProfileService;
  final GettingRatingList _gettingRatingList;

  BlogCommentDataLoaderImpl(
    this._usersCache,
    this._gettingProfileService,
    this._gettingRatingList,
  );

  @override
  Future<LoadedBlogPostComment> load(BlogPostComment comment) async {
    final futures = <Future>[];

    UserData? profile = _usersCache.get(comment.bitrixID);

    if (profile == null) {
      futures.add(
        _gettingProfileService.getProfileByAuthorIdFromPost(
          authorId: comment.bitrixID,
        ),
      );
    }

    futures.add(
      _gettingRatingList.getRatingList(
        voteKeySigned: comment.keySigned,
      ),
    );

    final data = await Future.wait(futures);

    final ratingListIndex = profile == null ? 1 : 0;
    profile ??= data.first;

    final blogPostCommentWithLoadedInfo = LoadedBlogPostComment(
      comment: comment,
      author: profile!,
      ratingList: data[ratingListIndex] ?? RatingList(),
    );

    _usersCache.save(
      comment.bitrixID,
      profile,
    );

    return blogPostCommentWithLoadedInfo;
  }
}
