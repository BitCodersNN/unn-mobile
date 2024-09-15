import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed_post_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/getting_vote_key_signed.dart';

class FeedPostDataLoaderImpl implements FeedPostDataLoader {
  final LRUCacheUserData _lruCacheProfile;
  final GettingProfile _gettingProfileService;
  final GettingVoteKeySigned _gettingVoteKeySigned;
  final GettingFileData _gettingFileData;
  final GettingRatingList _gettingRatingList;

  FeedPostDataLoaderImpl(
    this._lruCacheProfile,
    this._gettingProfileService,
    this._gettingFileData,
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

    for (final fileId in data.files ?? []) {
      futures.add(_gettingFileData.getFileData(id: int.parse(fileId)));
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

    final startPosFilesInData = postAuthor == null ? 1 : 0;
    final posRatingListInData = startPosFilesInData + (data.files ?? []).length;
    postAuthor ??= loadedData.first;
    if (postAuthor != null) {
      _lruCacheProfile.save(data.bitrixID, postAuthor);
    }

    final List<FileData?> files = List<FileData?>.from(
      loadedData.getRange(
        startPosFilesInData,
        posRatingListInData,
      ),
    );
    final List<FileData> filteredFiles = files //
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
    return PostWithLoadedInfo(
      author: postAuthor,
      post: data,
      files: filteredFiles,
      ratingList: loadedData[posRatingListInData] ?? RatingList(),
    );
  }
}
