import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/services/interfaces/base_file_uploader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class LogoUploaderImpl extends BaseFileUploader {
  LogoUploaderImpl(LoggerService loggerService)
      : super(
          loggerService,
          ApiPaths.gitHubHost,
          path: '${ApiPaths.gitRepository}/main',
        );
}
