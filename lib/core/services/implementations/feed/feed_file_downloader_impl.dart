import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/base_file_downloader.dart';

class FeedFileDownloaderImpl extends BaseFileDownloaderService {
  final AuthorizationService _authorisationService;
  FeedFileDownloaderImpl(
    super.loggerService,
    AuthorizationService authorisationService,
  )   : _authorisationService = authorisationService,
        super(
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
