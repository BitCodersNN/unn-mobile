import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed_post_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/getting_vote_key_signed.dart';

class FeedPostDataLoaderImpl implements FeedPostDataLoader {
  final LRUCacheUserData _lruCacheProfile;
  final GettingProfile _gettingProfileService;
  final GettingVoteKeySigned _gettingVoteKeySigned;
  final GettingRatingList _gettingRatingList;

  FeedPostDataLoaderImpl(
    this._lruCacheProfile,
    this._gettingProfileService,
    this._gettingRatingList,
    this._gettingVoteKeySigned,
  );
  @override
  Future<PostWithLoadedInfo> load(BlogData data) async {
    final futures = <Future>[];

    UserData? postAuthor = _lruCacheProfile.get(data.bitrixID);

    if (postAuthor == null) {
      futures.add(
        _gettingProfileService.getProfileByAuthorIdFromPost(
          authorId: data.bitrixID,
        ),
      );
    }

    futures.add(
      _gettingVoteKeySigned
          .getVoteKeySigned(authorId: data.bitrixID, postId: data.id)
          .then((voteKeySigned) {
        data.keySigned = voteKeySigned;
        return _gettingRatingList.getRatingList(
          voteKeySigned: voteKeySigned ?? '',
        );
      }),
    );

    final loadedData = await Future.wait(futures);
    final ratingList = loadedData[postAuthor == null ? 1 : 0] ?? RatingList();

    postAuthor ??= loadedData.first;
    if (postAuthor != null) {
      _lruCacheProfile.save(data.bitrixID, postAuthor);
    }
    return PostWithLoadedInfo(
      author: postAuthor,
      post: data,
      ratingList: ratingList,
    );
  }
}
