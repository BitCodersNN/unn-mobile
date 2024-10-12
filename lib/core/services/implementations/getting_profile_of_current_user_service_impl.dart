part of 'library.dart';

class GettingProfileOfCurrentUserImpl implements GettingProfileOfCurrentUser {
  final AuthorizationService _authorisationService;
  final LoggerService _loggerService;

  GettingProfileOfCurrentUserImpl(
    this._authorisationService,
    this._loggerService,
  );
  @override
  Future<UserData?> getProfileOfCurrentUser() async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.currentProfile,
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            _authorisationService.sessionId ?? '',
      },
    );

    HttpClientResponse response;
    try {
      response = await requestSender.get();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      _loggerService.log('statusCode = $statusCode');
      return null;
    }

    dynamic jsonMap;
    try {
      jsonMap =
          jsonDecode(await HttpRequestSender.responseToStringBody(response));
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    UserData? userData;
    try {
      userData = jsonMap[ProfilesStrings.type] == ProfilesStrings.student
          ? StudentData.fromJson(jsonMap)
          : jsonMap[ProfilesStrings.type] == ProfilesStrings.employee
              ? EmployeeData.fromJson(jsonMap)
              : null;
    } catch (e, stackTrace) {
      _loggerService.logError(e, stackTrace, information: [jsonMap.toString()]);
    }

    return userData;
  }
}
