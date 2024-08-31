import 'dart:convert';
import 'dart:io';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/mark_by_subject.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_grade_book.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class _JsonKeys {
  static const String semesters = 'semesters';
  static const String semester = 'semester';
  static const String data = 'data';
}

class GettingGradeBookImpl implements GettingGradeBook {
  final _loggerService = Injector.appInstance.get<LoggerService>();
  @override
  Future<Map<int, List<MarkBySubject>>?> getGradeBook() async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requestSender = HttpRequestSender(
      path: ApiPaths.marks,
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
      _loggerService.log('statusCode = $statusCode');
      return null;
    }

    dynamic jsonMap;
    try {
      jsonMap = jsonDecode(
        await HttpRequestSender.responseToStringBody(
          response,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final Map<int, List<MarkBySubject>> marks = {};
    for (final course in jsonMap) {
      for (final semesterInfo in course[_JsonKeys.semesters] ?? []) {
        final semester = semesterInfo[_JsonKeys.semester]?.toInt();
        final data = semesterInfo[_JsonKeys.data] ?? [];
        if (semester != null) {
          final List<MarkBySubject> semesterMarks = data
              .map<MarkBySubject>(
                (markBySubject) => MarkBySubject.fromJson(markBySubject),
              )
              .toList();
          marks[semester] = semesterMarks;
        }
      }
    }
    return marks;
  }
}
