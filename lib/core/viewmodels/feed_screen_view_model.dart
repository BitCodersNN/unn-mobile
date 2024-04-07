import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/services/interfaces/feed_stream_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/post_with_loaded_info_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class FeedScreenViewModel extends BaseViewModel {
  final _feedStreamUpdater = Injector.appInstance.get<FeedUpdaterService>();
  final _postWithLoadedInfoProvider =
      Injector.appInstance.get<PostWithLoadedInfoProvider>();
  DateTime? _dateTimeWhenPostsWereLastSaved;
  List<PostWithLoadedInfo> get posts => _feedStreamUpdater.feedPosts;

  bool get isLoadingPosts => _feedStreamUpdater.isBusy;

  DateTime get dateTimeWhenPostsWereLastSaved =>
      _dateTimeWhenPostsWereLastSaved ?? DateTime.now();

  void init() {
    _udateDateTimeWhenPostsWereLastSaved();
    _feedStreamUpdater.addListener(() {
      notifyListeners();
    });
  }

  Future<void> updateFeed() async {
    _udateDateTimeWhenPostsWereLastSaved();
    await _feedStreamUpdater.updateFeed();
  }

  void loadNextPage() {
    _feedStreamUpdater.loadNextPage();
  }

  void _udateDateTimeWhenPostsWereLastSaved() async {
    _dateTimeWhenPostsWereLastSaved = _dateTimeWhenPostsWereLastSaved =
        await _postWithLoadedInfoProvider.getDateTimeWhenPostsWereLastSaved();
    await _postWithLoadedInfoProvider
        .saveDateTimeWhenPostsWereLastSaved(DateTime.now());
  }
}
