import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/services/interfaces/base_file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class LogoDownloaderImpl extends BaseFileDownloader {
  LogoDownloaderImpl(LoggerService loggerService)
      : super(
          loggerService,
          ApiPaths.gitHubHost,
          path: '${ApiPaths.gitRepository}/main',
        );
}
