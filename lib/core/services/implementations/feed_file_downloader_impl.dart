import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_service_impl.dart';
import 'package:unn_mobile/core/services/interfaces/base_file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class FeedFileDownloaderImpl extends BaseFileDownloaderService {
  final AuthorizationServiceImpl _authorisationService;
  FeedFileDownloaderImpl(
    LoggerService loggerService,
    AuthorizationServiceImpl authorisationService,
  )   : _authorisationService = authorisationService,
        super(
          loggerService,
          ApiPaths.unnHost,
          cookies: {
            SessionIdentifierStrings.sessionIdCookieKey:
                authorisationService.sessionId ?? '',
          },
        ) {
    _authorisationService.addListener(_updateCookies);
  }

  void _updateCookies() {
    final newCookie = {
      SessionIdentifierStrings.sessionIdCookieKey:
          _authorisationService.sessionId ?? '',
    };
    super.updateCookies(newCookie);
  }
}
