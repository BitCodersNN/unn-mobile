import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed_stream_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/getting_vote_key_signed.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/post_with_loaded_info_provider.dart';

class FeedStreamUpdaterServiceImpl
    with ChangeNotifier
    implements FeedUpdaterService {
  final GettingBlogPosts _gettingBlogPostsService;
  final GettingProfile _gettingProfileService;
  final GettingFileData _gettingFileData;
  final GettingRatingList _gettingRatingList;
  final GettingVoteKeySigned _gettingVoteKeySigned;
  final PostWithLoadedInfoProvider _postWithLoadedInfoProvider;
  final LRUCacheUserData _lruCacheProfile;
  final LoggerService _loggerService;

  bool _busy = false;

  CancelableOperation<void>? _currentOperation;

  final List<PostWithLoadedInfo> _postsList = [];

  int _lastLoadedPage = 0;

  DateTime? _lastViewedPostDateTime;

  FeedStreamUpdaterServiceImpl(
    this._gettingBlogPostsService,
    this._gettingProfileService,
    this._gettingFileData,
    this._gettingRatingList,
    this._gettingVoteKeySigned,
    this._postWithLoadedInfoProvider,
    this._lruCacheProfile,
    this._loggerService,
  );

  @override
  DateTime? get lastViewedPostDateTime {
    final lastViewedPostDateTime = _lastViewedPostDateTime;
    if (_postsList.isNotEmpty) {
      _lastViewedPostDateTime = _postsList.first.post.datePublish;
    }
    return lastViewedPostDateTime;
  }

  @override
  bool get isBusy => _busy;

  @override
  Future<bool> checkForUpdates() {
    throw UnimplementedError();
  }

  @override
  int get lastLoadedPage => _lastLoadedPage;

  @override
  Future<void> loadNextPage() async {
    if (_busy) {
      return;
    }
    try {
      _busy = true;
      notifyListeners();
      final posts = await _gettingBlogPostsService.getBlogPosts(
        pageNumber: _lastLoadedPage + 1,
      );
      if (_currentOperation != null) {
        await _currentOperation!.cancel();
      }
      _currentOperation = CancelableOperation.fromFuture(
        _addPostsToStream(posts, true),
      );
      await _currentOperation?.valueOrCancellation();
      _lastLoadedPage++;
    } on Exception catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    } finally {
      _busy = false;
    }
  }

  @override
  List<PostWithLoadedInfo> get feedPosts => _postsList;

  @override
  Future<void> updateFeed() async {
    try {
      _busy = true;
      _lastViewedPostDateTime =
          await _postWithLoadedInfoProvider.getDateTimePublishedPost() ??
              DateTime.now();

      final newPosts = await _gettingBlogPostsService.getBlogPosts();

      if (newPosts != null) {
        await _postWithLoadedInfoProvider
            .saveDateTimePublishedPost(newPosts.first.datePublish);
        await _postWithLoadedInfoProvider.saveData(_postsList);

        await _currentOperation?.valueOrCancellation();
        _busy = true;
        _lastLoadedPage = 0;
        _postsList.clear();

        _currentOperation =
            CancelableOperation.fromFuture(_addPostsToStream(newPosts, true));
        await _currentOperation?.valueOrCancellation();
      }
    } on Exception catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    } finally {
      _busy = false;
    }
  }

  Future<void> _addPostsToStream(List<BlogData>? posts, bool notify) async {
    if (posts == null) {
      throw Exception('Could not load posts');
    }

    for (final post in posts) {
      _busy = true;
      final futures = <Future>[];

      UserData? postAuthor = _lruCacheProfile.get(post.bitrixID);

      if (postAuthor == null) {
        futures.add(
          _gettingProfileService.getProfileByAuthorIdFromPost(
            authorId: post.bitrixID,
          ),
        );
      }

      for (final fileId in post.files ?? []) {
        futures.add(_gettingFileData.getFileData(id: int.parse(fileId)));
      }

      futures.add(
        _gettingVoteKeySigned
            .getVoteKeySigned(
          authorId: post.bitrixID,
          postId: post.id,
        )
            .then((voteKeySigned) {
          post.keySigned = voteKeySigned;
          return _gettingRatingList.getRatingList(
            voteKeySigned: voteKeySigned ?? '',
          );
        }),
      );

      final data = await Future.wait(futures);

      final startPosFilesInData = postAuthor == null ? 1 : 0;
      final posRatingListInData =
          startPosFilesInData + (post.files ?? []).length;
      postAuthor ??= data.first;

      if (postAuthor == null) {
        return;
      }

      _lruCacheProfile.save(post.bitrixID, postAuthor);

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

      _postsList.add(
        PostWithLoadedInfo(
          author: postAuthor,
          post: post,
          files: filteredFiles,
          ratingList: data[posRatingListInData] ?? RatingList(),
        ),
      );

      if (notify) {
        notifyListeners();
      }
    }
  }
}
