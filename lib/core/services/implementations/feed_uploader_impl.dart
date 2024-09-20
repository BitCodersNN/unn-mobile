import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/services/interfaces/base_file_uploader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class FeedUploaderImpl extends BaseFileUploader {
  FeedUploaderImpl(
    LoggerService loggerService,
    String sessionId,
  ) : super(
          loggerService,
          ApiPaths.unnHost,
          cookies: {
            SessionIdentifierStrings.sessionIdCookieKey: sessionId,
          },
        );
}
