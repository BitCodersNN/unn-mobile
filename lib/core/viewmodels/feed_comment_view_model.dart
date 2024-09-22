import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/viewmodels/attached_file_view_model.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_comment_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/reaction_view_model.dart';

class FeedCommentViewModel extends BaseViewModel {
  factory FeedCommentViewModel.cached(FeedCommentCacheKey key) {
    return Injector.appInstance
        .get<FeedCommentViewModelFactory>()
        .getViewModel(key);
  }

  final _bbTagRegex = RegExp(r'\[[^\[\]]+\]');

  final HtmlUnescape _unescaper = HtmlUnescape();
  late BlogPostComment comment;

  String get message => _unescaper.convert(comment.message);
  bool _renderMessage = false;
  bool get renderMessage => _renderMessage && !isBusy;

  late ReactionViewModel _reactionViewModel;
  ReactionViewModel get reactionViewModel => _reactionViewModel;

  late ProfileViewModel _profileViewModel;
  ProfileViewModel get profileViewModel => _profileViewModel;

  final List<AttachedFileViewModel> attachedFileViewModels = [];

  FeedCommentViewModel();

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
