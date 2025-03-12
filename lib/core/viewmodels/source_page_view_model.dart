import 'dart:async';

import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';
import 'package:unn_mobile/core/models/distance_learning/semester.dart';
import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/source_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_course_semester_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_course_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/source_course_view_model.dart';

class SourcePageViewModel extends BaseViewModel {
  final DistanceCourseSemesterService _semesterService;
  final DistanceCourseService _courseService;
  final AuthDataProvider _authDataProvider;
  final SourceAuthorisationService _sourceAuthorisationService;

  final Map<Semester, Iterable<SourceCourseViewModel>> _materialsMap = {};

  String? error;
  bool get hasError => error != null;

  Semester? _currentSemester;

  SourcePageViewModel(
    this._semesterService,
    this._courseService,
    this._authDataProvider,
    this._sourceAuthorisationService,
  );

  Iterable<Semester> _semesters = [];

  Iterable<Semester> get semesters => _semesters;

  Semester? get currentSemester => _currentSemester;

  Iterable<SourceCourseViewModel> get courses =>
      _materialsMap[_currentSemester] ?? [];

  void init() {
    _init();
  }

  FutureOr<void> _init() => busyCallAsync(
        () async {
          error = null;
          final data = await _authDataProvider.getData();
          final authRes =
              await _sourceAuthorisationService.auth(data.login, data.password);
          if (authRes != AuthRequestResult.success) {
            error = 'Не удалось авторизоваться';
            return;
          }

          final semesters = await _semesterService.getSemesters();
          semesters?.sort(
            (a, b) {
              return a.year == b.year
                  ? a.semester.compareTo(b.semester)
                  : a.year.compareTo(b.year);
            },
          );
          _semesters = semesters ?? [];
          _currentSemester = _semesters.lastOrNull;
          await _initCurrentSemester();
        },
      );

  FutureOr<void> initCurrentSemester() => busyCallAsync(_initCurrentSemester);

  FutureOr<void> _initCurrentSemester() async {
    if (_currentSemester == null) {
      return;
    }
    final courses =
        await _courseService.getDistanceCourses(semester: _currentSemester!);
    _materialsMap[_currentSemester!] =
        courses?.map((c) => SourceCourseViewModel(c)) ?? [];
    if (courses == null) {
      error = 'Не удалось загрузить';
    }
  }
}
