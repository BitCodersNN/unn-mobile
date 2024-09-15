import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/loaded_blog_post_comment.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/blog_comment_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';

class BlogCommentDataLoaderImpl implements BlogCommentDataLoader {
  final LRUCacheUserData _usersCache;
  final GettingProfile _gettingProfileService;
  final GettingFileData _gettingFileDataService;
  final GettingRatingList _gettingRatingList;

  BlogCommentDataLoaderImpl(
    this._usersCache,
    this._gettingProfileService,
    this._gettingFileDataService,
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

    for (final fileId in comment.attachedFiles) {
      futures.add(_gettingFileDataService.getFileData(id: fileId));
    }

    futures.add(
      _gettingRatingList.getRatingList(
        voteKeySigned: comment.keySigned,
      ),
    );

    final data = await Future.wait(futures);

    final startPosFilesInData = profile == null ? 1 : 0;
    final posRatingListInData =
        startPosFilesInData + (comment.attachedFiles).length;

    profile ??= data.first;

    final List<FileData?> files = List<FileData?>.from(
      data.getRange(
        startPosFilesInData,
        posRatingListInData,
      ),
    );
    final List<FileData> filteredFiles = files //
        .where((element) => element != null)
        .map((e) => e!)
        .toList();

    final blogPostCommentWithLoadedInfo = LoadedBlogPostComment(
      comment: comment,
      author: profile!,
      files: filteredFiles,
      ratingList: data[posRatingListInData] ?? RatingList(),
    );

    _usersCache.save(
      comment.bitrixID,
      profile,
    );

    return blogPostCommentWithLoadedInfo;
  }
}
