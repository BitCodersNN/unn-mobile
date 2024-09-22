import 'package:event/event.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/attached_file_view_model.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_post_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/reaction_view_model.dart';

class FeedPostViewModel extends BaseViewModel {
  factory FeedPostViewModel.cached(FeedPostCacheKey key) {
    return Injector.appInstance
        .get<FeedPostViewModelFactory>()
        .getViewModel(key);
  }

  final GettingBlogPosts _gettingBlogPosts;
  final LoggerService _loggerService;

  final HtmlUnescape _unescaper = HtmlUnescape();

  final onError = Event();

  late BlogData blogData;

  int get authorId => blogData.bitrixID;

  String get postText => _unescaper.convert(blogData.detailText.trim());

  int get filesCount => blogData.files?.length ?? 0;

  FeedPostViewModel(
    this._gettingBlogPosts,
    this._loggerService,
  );

  DateTime get postTime => blogData.datePublish;

  late ProfileViewModel _profileViewModel;
  ProfileViewModel get profileViewModel => _profileViewModel;

  late ReactionViewModel _reactionViewModel;
  ReactionViewModel get reactionViewModel => _reactionViewModel;

  final List<AttachedFileViewModel> attachedFileViewModels = [];

  int get commentsCount => blogData.numberOfComments;

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
}
