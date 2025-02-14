import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/feed/blog_post_comment.dart';
import 'package:unn_mobile/core/models/feed/blog_post_comment_data.dart';
import 'package:unn_mobile/core/viewmodels/attached_file_view_model.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_comment_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/reaction_view_model.dart';

class FeedCommentViewModel extends BaseViewModel {
  final HtmlUnescape _unescaper = HtmlUnescape();

  final List<AttachedFileViewModel> attachedFileViewModels = [];

  late BlogPostCommentData comment;

  late ReactionViewModel _reactionViewModel;
  late ProfileViewModel _profileViewModel;

  FeedCommentViewModel();
  factory FeedCommentViewModel.cached(FeedCommentCacheKey key) {
    return Injector.appInstance
        .get<FeedCommentViewModelFactory>()
        .getViewModel(key);
  }

  String get message => _unescaper.convert(comment.message);
  ProfileViewModel get profileViewModel => _profileViewModel;

  ReactionViewModel get reactionViewModel => _reactionViewModel;

  bool get renderMessage => !isBusy;

  void init(BlogPostCommentData comment) {
    this.comment = comment;

    _reactionViewModel = ReactionViewModel.cached(comment.authorBitrixId)
      ..init(voteKeySigned: comment.keySigned);
    _profileViewModel = ProfileViewModel.cached(comment.authorBitrixId)
      ..init(loadFromPost: true, userId: comment.authorBitrixId);
    attachedFileViewModels.clear();
    attachedFileViewModels.addAll(
      comment.attachedFiles.map((f) => AttachedFileViewModel.cached(f)),
    );
    notifyListeners();
  }

  void initFromFullInfo(BlogPostComment comment) {
    this.comment = comment.data;
    _profileViewModel =
        ProfileViewModel.cached(comment.userShortInfo.bitrixId ?? 0)
          ..initFromShortInfo(comment.userShortInfo);
    _reactionViewModel = ReactionViewModel.cached(comment.data.id)
      ..initFull(comment.data.keySigned, comment.ratingList!);
    attachedFileViewModels.clear();
    attachedFileViewModels.addAll(
      comment.attachFiles.map(
        (file) => AttachedFileViewModel.cached(file.id)..initFromFileData(file),
      ),
    );
    notifyListeners();
  }
}
