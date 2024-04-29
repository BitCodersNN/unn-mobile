import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/profiles_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';

class GettingProfileImpl implements GettingProfile {
  final String _pathSecondPartForGettingId = 'bx/';
  final String _id = 'id';

  @override
  Future<int?> getProfileIdByAuthorIdFromPost({required int authorId}) async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requestSender = HttpRequestSender(
      path: ApiPaths.user + _pathSecondPartForGettingId + authorId.toString(),
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            authorisationService.sessionId ?? '',
      },
    );

    HttpClientResponse response;
    try {
      response = await requestSender.get(timeoutSeconds: 5);
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      await FirebaseCrashlytics.instance.log(
        '${runtimeType.toString()}: statusCode = $statusCode; authorId = $authorId',
      );
      return null;
    }

    int? id;
    try {
      id = jsonDecode(
        await HttpRequestSender.responseToStringBody(response),
      )[_id];
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }

    return id;
  }

  @override
  Future<UserData?> getProfile({required int userId}) async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requestSender = HttpRequestSender(
      path: ApiPaths.user + userId.toString(),
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
      await FirebaseCrashlytics.instance.log(
        '${runtimeType.toString()}: statusCode = $statusCode; userId = $userId',
      );
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
      await FirebaseCrashlytics.instance
          .recordError(error, stackTrace, information: [jsonMap.toString()]);
    }

    return userData;
  }

  @override
  Future<UserData?> getProfileByAuthorIdFromPost({
    required int authorId,
  }) async {
    final userId = await getProfileIdByAuthorIdFromPost(authorId: authorId);
    if (userId == null) {
      return null;
    }
    return await getProfile(userId: userId);
  }
}
