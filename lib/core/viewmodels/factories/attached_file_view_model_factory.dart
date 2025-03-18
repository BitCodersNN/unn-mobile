import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/services/interfaces/feed/feed_file_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/file_data_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/attached_file_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/cached_view_model_factory_base.dart';

typedef AttachedFileCacheKey = int;

class AttachedFileViewModelFactory extends CachedViewModelFactoryBase<
    AttachedFileCacheKey, AttachedFileViewModel> {
  AttachedFileViewModelFactory() : super(100);

  @override
  @protected
  AttachedFileViewModel createViewModel(key) {
    return AttachedFileViewModel(
      getService<FileDataService>(),
      getService<LoggerService>(),
      getService<FeedFileDownloaderService>(),
    );
  }
}
