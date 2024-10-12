part of 'package:unn_mobile/core/viewmodels/library.dart';

class FeedCommentViewModel extends BaseViewModel {
  final _bbTagRegex = RegExp(r'\[[^\[\]]+\]');

  final HtmlUnescape _unescaper = HtmlUnescape();

  final List<AttachedFileViewModel> attachedFileViewModels = [];

  late BlogPostComment comment;

  late ReactionViewModel _reactionViewModel;
  late ProfileViewModel _profileViewModel;

  bool _renderMessage = false;

  FeedCommentViewModel();
  factory FeedCommentViewModel.cached(FeedCommentCacheKey key) {
    return Injector.appInstance
        .get<FeedCommentViewModelFactory>()
        .getViewModel(key);
  }

  String get message => _unescaper.convert(comment.message);
  ProfileViewModel get profileViewModel => _profileViewModel;

  ReactionViewModel get reactionViewModel => _reactionViewModel;

  bool get renderMessage => _renderMessage && !isBusy;

  void init(BlogPostComment comment) {
    this.comment = comment;
    _renderMessage =
        comment.message.replaceAll(_bbTagRegex, '').trim().isNotEmpty;

    _reactionViewModel = ReactionViewModel.cached(comment.bitrixID)
      ..init(voteKeySigned: comment.keySigned);
    _profileViewModel = ProfileViewModel.cached(comment.bitrixID)
      ..init(loadFromPost: true, userId: comment.bitrixID);
    attachedFileViewModels.clear();
    attachedFileViewModels.addAll(
      comment.attachedFiles.map((f) => AttachedFileViewModel.cached(f)),
    );
    notifyListeners();
  }
}
