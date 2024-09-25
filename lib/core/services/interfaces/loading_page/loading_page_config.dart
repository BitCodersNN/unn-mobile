import 'package:unn_mobile/core/models/loading_page_data.dart';

abstract interface class LoadingPageConfigService {
  Future<List<LoadingPageModel>?> getLoadingPages();
}
