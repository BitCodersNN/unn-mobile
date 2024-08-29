import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/profiles_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';

class GettingProfileOfCurrentUserImpl implements GettingProfileOfCurrentUser {
  final AuthorizationService authorisationService;

  GettingProfileOfCurrentUserImpl(this.authorisationService);
  @override
  Future<UserData?> getProfileOfCurrentUser() async {
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
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      await FirebaseCrashlytics.instance
          .log('${runtimeType.toString()}: statusCode = $statusCode');
      return null;
    }

    dynamic jsonMap;
    try {
      jsonMap =
          jsonDecode(await HttpRequestSender.responseToStringBody(response));
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
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
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, information: [jsonMap.toString()]);
    }

    return userData;
  }
}
