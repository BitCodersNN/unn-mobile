import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/mark_by_subject.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_record_book.dart';

class _JsonKeys {
  static const String semesters = 'semesters';
  static const String semester = 'semester';
  static const String data = 'data';
}

class GettingRecordBookImpl implements GettingRecordBook {
  final String _path = 'bitrix/vuz/api/marks2';
  final String _sessionIdCookieKey = "PHPSESSID";

  @override
  Future<Map<int, List<MarkBySubject>>?> getRecordBook() async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requestSender = HttpRequestSender(path: _path, cookies: {
      _sessionIdCookieKey: authorisationService.sessionId ?? '',
    });

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
        '${runtimeType.toString()}: statusCode = $statusCode',
      );
      return null;
    }

    dynamic jsonMap;
    try {
      jsonMap = jsonDecode(await HttpRequestSender.responseToStringBody(
        response,
      ));
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    Map<int, List<MarkBySubject>> marks = {};
    for (final course in jsonMap) {
      for (final semesterInfo in course[_JsonKeys.semesters] ?? []) {
        final semester = semesterInfo[_JsonKeys.semester]?.toInt();
        final data = semesterInfo[_JsonKeys.data] ?? [];
        if (semester != null) {
          List<MarkBySubject> semesterMarks = data
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
