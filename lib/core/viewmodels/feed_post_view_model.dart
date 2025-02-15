import 'package:event/event.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/providers/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/attached_file_view_model.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_post_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/feed_comment_view_model.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/reaction_view_model.dart';

class FeedPostViewModel extends BaseViewModel {
  final BlogPostService _postsService;
  final LoggerService _loggerService;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;

  final HtmlUnescape _unescaper = HtmlUnescape();

  final List<AttachedFileViewModel> attachedFileViewModels = [];

  final onError = Event();

  late BlogPostData blogData;

  late ProfileViewModel _profileViewModel;

  late ReactionViewModel _reactionViewModel;

  final List<FeedCommentViewModel> comments = [];

  FeedPostViewModel(
    this._postsService,
    this._loggerService,
    this._lastFeedLoadDateTimeProvider,
  );
  factory FeedPostViewModel.cached(FeedPostCacheKey key) {
    return Injector.appInstance
        .get<FeedPostViewModelFactory>()
        .getViewModel(key);
  }

  int get authorId => blogData.authorBitrixId;

  int get commentsCount => blogData.numberOfComments;

  int get filesCount => blogData.files?.length ?? 0;

  bool get isNewPost =>
      _lastFeedLoadDateTimeProvider.lastFeedLoadDateTime?.isBefore(postTime) ??
      false;

  String get postText => _unescaper.convert(blogData.detailText.trim());

  DateTime get postTime => blogData.datePublish.toLocal();

  ProfileViewModel get profileViewModel => _profileViewModel;

  ReactionViewModel get reactionViewModel => _reactionViewModel;

  void initFromFullInfo(BlogPost post) {
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
    final post = await _postsService.getBlogPost(id: blogData.id);
    if (post == null) {
      _loggerService.log('Failed to refresh post');
      return;
    }
    initFromFullInfo(post);
  }
}
