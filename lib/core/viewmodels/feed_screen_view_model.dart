import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/services/interfaces/feed_stream_updater_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class FeedScreenViewModel extends BaseViewModel {
  final FeedUpdaterService _feedStreamUpdater =
      Injector.appInstance.get<FeedUpdaterService>();

  List<PostWithLoadedInfo> get posts => _feedStreamUpdater.feedPosts;

  bool get isLoadingPosts => _feedStreamUpdater.isBusy;

  void init() {
    _feedStreamUpdater.addListener(() {
      notifyListeners();
    });
  }

  Future<void> updateFeed() async {
    await _feedStreamUpdater.updateFeed();
  }

  void loadNextPage() {
    _feedStreamUpdater.loadNextPage();
  }
}
