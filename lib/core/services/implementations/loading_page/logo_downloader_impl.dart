import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/services/interfaces/base_file_downloader.dart';

class LogoDownloaderServiceImpl extends BaseFileDownloaderService {
  LogoDownloaderServiceImpl(super.loggerService)
      : super(
          host: ApiPaths.gitHubHost,
          path: '${ApiPaths.gitRepository}/main',
        );
}
