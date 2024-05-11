import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/services/interfaces/feed_stream_updater_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class FeedScreenViewModel extends BaseViewModel {
  final _feedStreamUpdater = Injector.appInstance.get<FeedUpdaterService>();
  DateTime? _lastViewedPostDateTime;
  List<PostWithLoadedInfo> get posts => _feedStreamUpdater.feedPosts;
  bool get isLoadingPosts => _feedStreamUpdater.isBusy;

  Map<int, int> reactionsMap = {};

  void init() {
    _feedStreamUpdater.addListener(() {
      notifyListeners();
    });
  }

  Future<void> updateFeed() async {
    await _feedStreamUpdater.updateFeed();
  }

  bool isNewPost(DateTime dateTimePublish) {
    _lastViewedPostDateTime ??= _feedStreamUpdater.lastViewedPostDateTime;
    return _lastViewedPostDateTime!.isBefore(dateTimePublish);
  }

  void loadNextPage() {
    _feedStreamUpdater.loadNextPage();
  }

  void addLike(PostWithLoadedInfo post) {
    // print('Liked post: ${post.post.id}');
  }

  void addReaction(PostWithLoadedInfo post, int reactionId) {
    reactionsMap[post.post.id] = reactionId;

    // print('Reaction post: ${post.post.id}');
    // print('current reaction: ${reactionId}');
  }
}
