part of 'package:unn_mobile/core/viewmodels/library.dart';

class FeedPostViewModel extends BaseViewModel {
  final GettingBlogPosts _gettingBlogPosts;
  final LoggerService _loggerService;
  final LastFeedLoadDateTimeProvider _lastFeedLoadDateTimeProvider;

  final HtmlUnescape _unescaper = HtmlUnescape();

  final List<AttachedFileViewModel> attachedFileViewModels = [];

  final onError = Event();

  late BlogData blogData;

  late ProfileViewModel _profileViewModel;

  late ReactionViewModel _reactionViewModel;

  FeedPostViewModel(
    this._gettingBlogPosts,
    this._loggerService,
    this._lastFeedLoadDateTimeProvider,
  );
  factory FeedPostViewModel.cached(FeedPostCacheKey key) {
    return Injector.appInstance
        .get<FeedPostViewModelFactory>()
        .getViewModel(key);
  }

  int get authorId => blogData.bitrixID;

  int get commentsCount => blogData.numberOfComments;

  int get filesCount => blogData.files?.length ?? 0;

  bool get isNewPost =>
      _lastFeedLoadDateTimeProvider.lastFeedLoadDateTime?.isBefore(postTime) ??
      false;

  String get postText => _unescaper.convert(blogData.detailText.trim());

  DateTime get postTime => blogData.datePublish.toLocal();

  ProfileViewModel get profileViewModel => _profileViewModel;

  ReactionViewModel get reactionViewModel => _reactionViewModel;

  void init(BlogData blogData) {
    this.blogData = blogData;

    _profileViewModel = ProfileViewModel.cached(blogData.bitrixID)
      ..init(loadFromPost: true, userId: blogData.bitrixID);
    _reactionViewModel = ReactionViewModel.cached(blogData.bitrixID)
      ..init(postId: blogData.id, authorId: blogData.bitrixID);
    attachedFileViewModels.clear();
    attachedFileViewModels.addAll(
      blogData.files?.map((f) => AttachedFileViewModel.cached(int.parse(f))) ??
          [],
    );
    notifyListeners();
  }

  Future<void> refresh() async {
    await _gettingBlogPosts.getBlogPosts(postId: blogData.id).then(
      (value) {
        if (value == null || value.isEmpty) {
          onError.broadcast();
          return;
        }
        init(value.first);
      },
    ).catchError((error, stack) {
      _loggerService.logError(error, stack);
      onError.broadcast();
    });
  }
}
