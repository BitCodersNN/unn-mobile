import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';

class GettingProfileOfCurrentUserImpl implements GettingProfileOfCurrentUser {
  final String _path = 'bitrix/vuz/api/profile/current';
  final String _sessionIdCookieKey = "PHPSESSID";

  @override
  Future<UserData?> getProfileOfCurrentUser() async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requstSender = HttpRequestSender(path: _path, cookies: {
      _sessionIdCookieKey: authorisationService.sessionId ?? '',
    });

    HttpClientResponse response;
    try {
      response = await requstSender.get();
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance
          .log("Exception: $error\nStackTrace: $stackTrace");
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      return null;
    }

    dynamic jsonMap;
    try {
      jsonMap =
          jsonDecode(await HttpRequestSender.responseToStringBody(response));
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance
          .log("Exception: $error\nStackTrace: $stackTrace");
      return null;
    }

    UserData? userData;
    try {
      userData = jsonMap['type'] == 'student'
          ? StudentData.fromJson(jsonMap)
          : jsonMap['type'] == 'employee'
              ? EmployeeData.fromJson(jsonMap)
              : null;
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, information: [jsonMap.toString()]);
    }

    return userData;
  }
}
