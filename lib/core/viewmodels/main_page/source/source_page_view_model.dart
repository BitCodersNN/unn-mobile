// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/authorisation/refresh_session_and_retrieve_data.dart';
import 'package:unn_mobile/core/models/distance_learning/semester.dart';
import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/source_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_course_semester_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_course_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_learning_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/session_checker_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/webinar_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_course_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_webinar_view_model.dart';

class _ErrorTexts {
  static const failedLoad = 'Не удалось загрузить';
}

class SourcePageViewModel extends BaseViewModel {
  final DistanceCourseSemesterService _semesterService;
  final DistanceCourseService _courseService;
  final AuthDataProvider _authDataProvider;
  final SourceAuthorisationService _sourceAuthorisationService;
  final WebinarService _webinarService;
  final DistanceLearningDownloaderService _downloader;
  final SessionCheckerService _sessionChecker;

  final Map<Semester, Iterable<SourceCourseViewModel>> _materialsMap = {};
  final Map<Semester, Map<DateTime, List<SourceWebinarViewModel>>>
      _webinarsMap = {};

  String? materialsError;
  String? webinarsError;

  bool get hasMaterialsError => materialsError != null;
  bool get hasWebinarsError => webinarsError != null;

  int? _currentSemester;

  SourcePageViewModel(
    this._semesterService,
    this._courseService,
    this._authDataProvider,
    this._sourceAuthorisationService,
    this._downloader,
    this._webinarService,
    this._sessionChecker,
  );

  List<Semester> _semesters = [];

  List<Semester> get semesters => _semesters;

  Semester? get currentSemester =>
      _currentSemester == null ? null : _semesters[_currentSemester!];

  int? get currentSemesterIndex => _currentSemester;

  Iterable<SourceCourseViewModel> get courses =>
      _materialsMap[currentSemester] ?? [];

  Map<DateTime, List<SourceWebinarViewModel>> get webinars =>
      _webinarsMap[currentSemester] ?? {};

  void init() {
    busyCallAsync(_init);
  }

  FutureOr<void> _init() async {
    resetAllErrors();

    final semesters = await refreshSessionAndRetrieveData(
      _sessionChecker,
      _sourceAuthorisationService,
      _authDataProvider,
      _semesterService.getSemesters,
    );
    semesters?.sort(
      (a, b) {
        return a.year == b.year
            ? a.semester.compareTo(b.semester)
            : a.year.compareTo(b.year);
      },
    );
    _semesters = semesters ?? [];
    _currentSemester = //
        _semesters.isNotEmpty
            ? _semesters.length - 1 //
            : null;
    await _initCurrentSemester();
  }

  FutureOr<void> refresh() => busyCallAsync(() async {
        if (_currentSemester == null) {
          return await _init();
        }
        await _initCurrentSemester();
      });

  FutureOr<void> _initCurrentSemester() async {
    if (currentSemester == null) {
      setAllErrors(_ErrorTexts.failedLoad);
      return;
    }
    resetAllErrors();
    final courses = await refreshSessionAndRetrieveData(
      _sessionChecker,
      _sourceAuthorisationService,
      _authDataProvider,
      () async => _courseService.getDistanceCourses(semester: currentSemester!),
    );
    _materialsMap[currentSemester!] =
        courses?.map((c) => SourceCourseViewModel(c, _downloader)) ?? [];
    if (courses == null) {
      setMaterialsError(_ErrorTexts.failedLoad);
    }

    final webinars = await refreshSessionAndRetrieveData(
      _sessionChecker,
      _sourceAuthorisationService,
      _authDataProvider,
      () async => await _webinarService.getWebinars(semester: currentSemester!),
    );
    final groupedWebinars = <DateTime, List<SourceWebinarViewModel>>{};

    if (webinars == null) {
      setWebinarsError(_ErrorTexts.failedLoad);
      return;
    }

    for (final webinar in webinars) {
      final date = DateUtils.dateOnly(webinar.dateTimeRange.start);
      final list = groupedWebinars[date] ?? [];
      list.add(SourceWebinarViewModel(webinar));
      groupedWebinars[date] = list;
    }

    _webinarsMap[currentSemester!] = groupedWebinars;
  }

  FutureOr<void> setSemester(int semester) async {
    if (semester < 0 || semester >= semesters.length) {
      return;
    }
    _currentSemester = semester;
    if (_materialsMap[currentSemester]?.isEmpty ?? true) {
      await refresh();
    }
    notifyListeners();
  }

  void resetMaterialsError() {
    materialsError = null;
  }

  void resetWebinarsError() {
    webinarsError = null;
  }

  void setMaterialsError(String error) {
    materialsError = error;
  }

  void setWebinarsError(String error) {
    webinarsError = error;
  }

  void resetAllErrors() {
    resetMaterialsError();
    resetWebinarsError();
  }

  void setAllErrors(String error) {
    setMaterialsError(error);
    setWebinarsError(error);
  }
}
