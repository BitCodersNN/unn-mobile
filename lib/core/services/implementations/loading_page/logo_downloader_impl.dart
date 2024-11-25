import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/services/interfaces/base_file_downloader.dart';

class LogoDownloaderServiceImpl extends BaseFileDownloaderService {
  LogoDownloaderServiceImpl(
    super._loggerService,
    super._baseApiHelper,
  ) : super(
          path: '${ApiPaths.gitRepository}/main',
        );
}
