import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class LoadingPageProvider
    implements DataProvider<List<LoadingPageModel>?> {
  @override
  Future<List<LoadingPageModel>?> getData();

  @override
  Future<void> saveData(List<LoadingPageModel>? loadingPages);

  @override
  Future<bool> isContained();
}
