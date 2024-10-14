part of 'library.dart';

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
