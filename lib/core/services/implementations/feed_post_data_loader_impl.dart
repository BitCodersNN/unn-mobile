import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/feed_post_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/getting_vote_key_signed.dart';

class FeedPostDataLoaderImpl implements FeedPostDataLoader {
  final GettingVoteKeySigned _gettingVoteKeySigned;
  final GettingRatingList _gettingRatingList;

  FeedPostDataLoaderImpl(
    this._gettingRatingList,
    this._gettingVoteKeySigned,
  );
  @override
  Future<PostWithLoadedInfo> load(BlogData data) async {
    final voteKeySigned = await _gettingVoteKeySigned.getVoteKeySigned(
      authorId: data.bitrixID,
      postId: data.id,
    );
    data.keySigned = voteKeySigned;
    final ratingList = await _gettingRatingList.getRatingList(
      voteKeySigned: voteKeySigned ?? '',
    );

    return PostWithLoadedInfo(
      post: data,
      ratingList: ratingList ?? RatingList(),
    );
  }
}
