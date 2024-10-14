part of 'library.dart';

class _GradeBookJsonKeys {
  static const String semesters = 'semesters';
  static const String semester = 'semester';
  static const String data = 'data';
}

class GettingGradeBookImpl implements GettingGradeBook {
  final AuthorizationService _authorizationService;
  final LoggerService _loggerService;

  GettingGradeBookImpl(
    this._authorizationService,
    this._loggerService,
  );
  @override
  Future<Map<int, List<MarkBySubject>>?> getGradeBook() async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.marks,
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
      for (final semesterInfo in course[_GradeBookJsonKeys.semesters] ?? []) {
        final semester = semesterInfo[_GradeBookJsonKeys.semester]?.toInt();
        final data = semesterInfo[_GradeBookJsonKeys.data] ?? [];
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
