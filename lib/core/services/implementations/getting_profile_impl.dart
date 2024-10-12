part of 'library.dart';

class GettingProfileImpl implements GettingProfile {
  final AuthorizationService _authorizationService;
  final LoggerService _loggerService;
  final String _pathSecondPartForGettingId = 'bx/';
  final String _id = 'id';

  GettingProfileImpl(
    this._authorizationService,
    this._loggerService,
  );

  @override
  Future<int?> getProfileIdByBitrixID({required int bitrixID}) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.user + _pathSecondPartForGettingId + bitrixID.toString(),
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            _authorizationService.sessionId ?? '',
      },
    );

    HttpClientResponse response;
    try {
      response = await requestSender.get(timeoutSeconds: 5);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      _loggerService.log('statusCode = $statusCode; authorId = $bitrixID');
      return null;
    }

    int? id;
    try {
      id = jsonDecode(
        await HttpRequestSender.responseToStringBody(response),
      )[_id];
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    return id;
  }

  @override
  Future<UserData?> getProfile({required int userId}) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.user + userId.toString(),
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            _authorizationService.sessionId ?? '',
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
      _loggerService.log('statusCode = $statusCode; userId = $userId');
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

    final profileJsonMap = jsonMap[ProfilesStrings.profilesKey][0];
    final userType = profileJsonMap[ProfilesStrings.type];

    // Костыль, т.к. на сайте есть небольшой процент профилей, отличающихся от остальных
    if (profileJsonMap[ProfilesStrings.user] == null) {
      profileJsonMap[ProfilesStrings.user] = jsonMap;
    }

    UserData? userData;
    try {
      userData = (userType == ProfilesStrings.student)
          ? StudentData.fromJson(profileJsonMap)
          : userType == ProfilesStrings.employee
              ? EmployeeData.fromJson(profileJsonMap)
              : UserData.fromJson(profileJsonMap);
    } catch (error, stackTrace) {
      _loggerService
          .logError(error, stackTrace, information: [jsonMap.toString()]);
    }

    return userData;
  }

  @override
  Future<UserData?> getProfileByAuthorIdFromPost({
    required int authorId,
  }) async {
    final userId = await getProfileIdByBitrixID(bitrixID: authorId);
    if (userId == null) {
      return null;
    }
    return await getProfile(userId: userId);
  }
}
