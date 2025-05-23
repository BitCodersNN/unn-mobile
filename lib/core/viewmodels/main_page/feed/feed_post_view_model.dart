// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:event/event.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/important_blog_post_acknowledgement_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/pinning_blog_post_service.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/attached_file_view_model.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_post_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_comment_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/reaction_view_model.dart';

class FeedPostViewModel extends BaseViewModel {
  final BlogPostService _postsService;
  final LoggerService _loggerService;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;
  final ImportantBlogPostAcknowledgementService _postAcknowledgementService;
  final PinningBlogPostService _pinningService;

  final HtmlUnescape _unescaper = HtmlUnescape();

  final List<AttachedFileViewModel> attachedFileViewModels = [];
  Iterable<String> get attachedImages => blogData.imageUrls ?? [];

  final onError = Event();

  late BlogPostData blogData;

  late ProfileViewModel _profileViewModel;

  late ReactionViewModel _reactionViewModel;

  bool get isPinned => _feedScreenViewModel?.isPostPinned(blogData.id) ?? false;

  bool get isAnnouncement =>
      _feedScreenViewModel?.isPostImportant(blogData.id) ?? false;

  final List<FeedCommentViewModel> comments = [];

  FeedScreenViewModel? _feedScreenViewModel;

  FeedPostViewModel(
    this._postsService,
    this._loggerService,
    this._lastFeedLoadDateTimeProvider,
    this._postAcknowledgementService,
    this._pinningService,
  );
  factory FeedPostViewModel.cached(FeedPostCacheKey key) {
    return Injector.appInstance
        .get<FeedPostViewModelFactory>()
        .getViewModel(key);
  }

  int get authorId => blogData.authorBitrixId;

  int get commentsCount => comments.length;

  int get filesCount => blogData.files?.length ?? 0;

  bool get isNewPost =>
      _lastFeedLoadDateTimeProvider.lastFeedLoadDateTime?.isBefore(postTime) ??
      false;

  String get postText => _unescaper.convert(blogData.detailText.trim());

  DateTime get postTime => blogData.datePublish.toLocal();

  ProfileViewModel get profileViewModel => _profileViewModel;

  ReactionViewModel get reactionViewModel => _reactionViewModel;

  void initFromFullInfo(BlogPost post, FeedScreenViewModel? feedVm) {
    _feedScreenViewModel = feedVm;

    blogData = post.data;
    comments
      ..clear()
      ..addAll(
        post.comments.map(
          (c) => FeedCommentViewModel.cached(c.data.id)..initFromFullInfo(c),
        ),
      );
    _profileViewModel =
        ProfileViewModel.cached(post.userShortInfo.bitrixId ?? 0)
          ..initFromShortInfo(post.userShortInfo);
    _reactionViewModel = ReactionViewModel.cached(post.data.id)
      ..initFull(post.data.keySigned!, post.ratingList);
    attachedFileViewModels
      ..clear()
      ..addAll(
        post.attachFiles.map(
          (file) =>
              AttachedFileViewModel.cached(file.id)..initFromFileData(file),
        ),
      );

    notifyListeners();
  }

  Future<void> refresh() async {
    await _feedScreenViewModel?.refreshFeatured();
    final post = await _postsService.getBlogPost(id: blogData.id);
    if (post == null) {
      _loggerService.log('Failed to refresh post');
      return;
    }
    initFromFullInfo(post, _feedScreenViewModel);
  }

  Future<void> togglePin() async {
    final pinnedId = blogData.pinnedId ?? 0;
    final success = isPinned
        ? await _pinningService.unpin(pinnedId)
        : await _pinningService.pin(pinnedId);

    if (success) {
      await _feedScreenViewModel?.refreshFeatured();
      notifyListeners();
    }
  }

  Future<void> markReadIfImportant() async {
    if (!isAnnouncement) {
      return;
    }
    if (await _postAcknowledgementService.read(blogData.id)) {
      await _feedScreenViewModel?.refreshFeatured();
      notifyListeners();
    }
  }
}
