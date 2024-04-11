import 'package:async/async.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/services/interfaces/feed_stream_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/post_with_loaded_info_provider.dart';

class FeedStreamUpdaterServiceImpl
    with ChangeNotifier
    implements FeedUpdaterService {
  final _gettingBlogPostsService = Injector.appInstance.get<GettingBlogPosts>();
  final _gettingProfileService = Injector.appInstance.get<GettingProfile>();
  final _postWithLoadedInfoProvider =
      Injector.appInstance.get<PostWithLoadedInfoProvider>();

  bool _busy = false;

  CancelableOperation<void>? _currentOperation;

  final List<PostWithLoadedInfo> _postsList = [];

  int _lastLoadedPage = 0;

  DateTime? _lastViewedPostDateTime;

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
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
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
          await _postWithLoadedInfoProvider.getDateTimePublishedPost();

      final newPosts = await _gettingBlogPostsService.getBlogPosts();

      if (newPosts != null) {
        if (_lastLoadedPage == 0) {
          await _postWithLoadedInfoProvider
              .saveDateTimePublishedPost(newPosts.first.datePublish);
          await _postWithLoadedInfoProvider.saveData(_postsList);
        }

        await _currentOperation?.valueOrCancellation();
        _busy = true;
        _postsList.clear();
        _currentOperation =
            CancelableOperation.fromFuture(_addPostsToStream(newPosts, true));
        await _currentOperation?.valueOrCancellation();
      }
    } on Exception catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    } finally {
      _busy = false;
    }
  }

  Future<void> _addPostsToStream(List<BlogData>? posts, bool notify) async {
    if (posts == null) {
      throw Exception("Could not load posts");
    }

    for (final post in posts) {
      _busy = true;
      final postAuthor = await _gettingProfileService
          .getProfileByAuthorIdFromPost(authorId: post.authorID);
      if (postAuthor != null) {
        _postsList.add(PostWithLoadedInfo(author: postAuthor, post: post));
        if (notify) {
          notifyListeners();
        }
      }
    }
  }
}
