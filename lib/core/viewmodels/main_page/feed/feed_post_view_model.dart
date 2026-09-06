// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:event/event.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/demo_mode_status.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/models/feed/important_blog_post.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_comments_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_detail_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/important_blog_post_acknowledgement_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/pinning_blog_post_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_post_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/attached_file_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_comment_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/reaction_view_model.dart';

class FeedPostViewModel extends BaseViewModel {
  final AuthorisationService _authorisationService;
  final BlogPostDetailService _postsService;
  final LoggerService _loggerService;
  final LastFeedLoadDateTimeProvider _feedUpdateTimeProvider;
  final ImportantBlogPostAcknowledgementService _postAcknowledgementService;
  final PinningBlogPostService _pinningService;
  final BlogPostCommentsService _commentsService;

  final HtmlUnescape _unescaper = HtmlUnescape();

  final List<AttachedFileViewModel> attachedFileViewModels = [];
  final onError = Event();

  BlogPostData? blogData;

  ProfileViewModel? _profileViewModel;

  ReactionViewModel? _reactionViewModel;

  bool _isAnnouncement = false;

  bool? _isAnnouncementRead;

  bool _commentsError = false;

  int? _announcementReadCount;

  int _currentCommentsPage = 1;

  final List<FeedCommentViewModel> comments = [];

  FeedScreenViewModel? _feedScreenViewModel;

  FeedPostViewModel(
    this._postsService,
    this._loggerService,
    this._feedUpdateTimeProvider,
    this._postAcknowledgementService,
    this._pinningService,
    this._authorisationService,
    this._commentsService,
  );

  factory FeedPostViewModel.cached(FeedPostCacheKey key) =>
      Injector.appInstance.get<FeedPostViewModelFactory>().getViewModel(key);
  Iterable<String> get attachedImages => blogData?.imageUrls ?? [];

  // Нужны для подтягивания html и всякого содержимого поста на фронте
  Map<String, String> get authHeaders =>
      _authorisationService.headers
          ?.map((key, value) => MapEntry(key, value.toString())) ??
      {};

  int? get authorId => blogData?.authorBitrixId;

  int get commentsCount => blogData?.numberOfComments ?? 0;

  int get filesCount => blogData?.fileIds?.length ?? 0;

  bool get isNewPost =>
      postTime != null && (lastUpdated?.isBefore(postTime!) ?? false);

  bool get isAnnouncement => _isAnnouncement;

  bool get isAnnouncementRead => _isAnnouncementRead ?? false;

  int get announcementReadCount => _announcementReadCount ?? 0;

  bool get isPinned =>
      _feedScreenViewModel?.isPostPinned(blogData?.id) ?? false;

  DateTime? get lastUpdated => _feedUpdateTimeProvider.lastFeedLoadDateTime;

  String get postText => _unescaper.convert(blogData?.detailText.trim() ?? '');

  bool get hasMoreComments => commentsCount != comments.length;

  bool get commentsError => _commentsError;

  DateTime? get postTime => blogData?.datePublish.toLocal();

  ProfileViewModel? get profileViewModel => _profileViewModel;

  ReactionViewModel? get reactionViewModel => _reactionViewModel;

  void initFromFullInfo(BlogPost post, FeedScreenViewModel? feedVm) {
    _feedScreenViewModel = feedVm;

    blogData = post.data;

    if (post is ImportantBlogPost) {
      _isAnnouncement = true;
      _isAnnouncementRead = post.isRead;
      _announcementReadCount = post.readCount;
    }
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

  Future<void> markReadIfImportant() async {
    if (DemoModeStatus.demoModeEnabled) {
      return;
    }
    if (blogData == null) {
      return;
    }
    if (!isAnnouncement) {
      return;
    }
    if (await _postAcknowledgementService.read(blogData!.id)) {
      _isAnnouncementRead = true;
      notifyListeners();
    }
  }

  Future<void> refresh({bool loadComments = false}) async {
    if (blogData == null) {
      _loggerService.log('Error: blog post tried to refresh while not loaded');
      return;
    }
    await _feedScreenViewModel?.refreshFeatured();
    final post = await _postsService.getBlogPostById(postId: blogData!.id);
    if (post == null) {
      _loggerService.log('Failed to refresh post');
      return;
    }
    initFromFullInfo(post, _feedScreenViewModel);
    if (loadComments) {
      await reloadComments();
    }
  }

  Future<void> reloadComments() async => busyCallAsync(() async {
        comments.clear();
        _currentCommentsPage = 1;
        await loadCommentsPage();
      });

  Future<void> loadCommentsPage({int page = 1}) async {
    _commentsError = false;
    final newComments = await _commentsService.getBlogPostComments(
      postId: blogData!.id,
      pageNumber: page,
    );
    if (newComments == null) {
      _commentsError = true;
    }
    comments.insertAll(
      0,
      newComments!.map(
        (c) => FeedCommentViewModel.cached(c.data.id)..initFromFullInfo(c),
      ),
    );
  }

  Future<void> loadMoreComments() async => busyCallAsync(() async {
        if (!hasMoreComments) {
          return;
        }
        await loadCommentsPage(page: _currentCommentsPage + 1);
        if (!commentsError) {
          _currentCommentsPage++;
        }
      });

  Future<void> togglePin() async {
    if (DemoModeStatus.demoModeEnabled) {
      return;
    }
    final pinnedId = blogData?.pinnedId ?? 0;
    final success = isPinned
        ? await _pinningService.unpin(pinnedId)
        : await _pinningService.pin(pinnedId);

    if (success) {
      await _feedScreenViewModel?.refreshFeatured();
      notifyListeners();
    }
  }
}
