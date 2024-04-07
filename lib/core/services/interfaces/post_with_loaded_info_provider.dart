import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/services/interfaces/data_provider.dart';

abstract interface class PostWithLoadedInfoProvider implements DataProvider<List<PostWithLoadedInfo>?> {
  @override
  Future<List<PostWithLoadedInfo>?> getData();

  Future<DateTime?> getDateTimeWhenPostsWereLastSaved();

  @override
  Future<bool> isContained();

  @override
  Future<void> saveData(List<PostWithLoadedInfo>? data);

  Future<void> saveDateTimeWhenPostsWereLastSaved(DateTime dateTime);
}
