import 'dart:convert';
import 'dart:io';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/profiles_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class GettingProfileOfCurrentUserImpl implements GettingProfileOfCurrentUser {
  final _loggerService = Injector.appInstance.get<LoggerService>();
  @override
  Future<UserData?> getProfileOfCurrentUser() async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requestSender = HttpRequestSender(
      path: ApiPaths.currentProfile,
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            authorisationService.sessionId ?? '',
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
      _loggerService.log('${runtimeType.toString()}: statusCode = $statusCode');
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
