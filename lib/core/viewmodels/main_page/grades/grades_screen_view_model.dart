// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/constants/academic_year.dart';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/grade_book/curriculum_semester.dart';
import 'package:unn_mobile/core/models/grade_book/grade_book_summary.dart';
import 'package:unn_mobile/core/models/grade_book/grade_statistics.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/providers/interfaces/grade_book/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/services/interfaces/grade_book/curriculum_service.dart';
import 'package:unn_mobile/core/services/interfaces/grade_book/grade_book_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grade_book_semester_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grade_semester_view_model.dart';

class GradesScreenViewModel extends BaseViewModel {
  final GradeBookService _gradeBookService;
  final MarkBySubjectProvider _markBySubjectProvider;
  final CurriculumService _curriculumService;
  final CurrentUserSyncStorage _userStorage;
  final DateTime Function() _currentTime;

  List<GradeBookSemesterViewModel> _semesters = const [];
  int? _selectedSemesterNumber;
  Map<int, CurriculumSemester>? _curriculum;
  bool _hasGradeBook = false;
  bool _hasError = false;
  Future<void>? _pendingLoad;

  GradesScreenViewModel(
    this._gradeBookService,
    this._markBySubjectProvider,
    this._curriculumService,
    this._userStorage, {
    DateTime Function()? currentTime,
  }) : _currentTime = currentTime ?? DateTime.now;

  List<GradeBookSemesterViewModel> get semesters => _semesters;

  int? get selectedSemesterNumber => _selectedSemesterNumber;

  int get selectedSemesterIndex => _semesters.indexWhere(
        (model) => model.number == _selectedSemesterNumber,
      );

  bool get hasGradeBook => _hasGradeBook;

  bool get hasError => _hasError;

  void selectSemester(int number) {
    if (disposed ||
        number == _selectedSemesterNumber ||
        !_semesters.any((model) => model.number == number)) {
      return;
    }
    _selectedSemesterNumber = number;
    notifyListeners();
  }

  Future<void> refresh() {
    if (disposed) {
      return Future.value();
    }
    return _pendingLoad ??= _load();
  }

  Future<void> _load() async {
    _hasError = false;
    setState(ViewState.busy);
    try {
      await _loadGradeBook();
    } catch (_) {
      if (!disposed) {
        _hasError = true;
      }
    } finally {
      _pendingLoad = null;
      if (!disposed) {
        setState(ViewState.idle);
      }
    }
  }

  Future<void> _loadGradeBook() async {
    final book = await _getGradeBook();
    final curriculum = await tryLoginAndRetrieveData(
      _curriculumService.getCurriculum,
      () => _curriculum,
    );
    if (disposed) {
      return;
    }
    final summary = book == null ? null : GradeBookSummary.fromGradeBook(book);
    _curriculum = curriculum;
    final plannedSemesters = _plannedSemesters(
      curriculum ?? const {},
      book ?? const {},
      summary?.overall ?? GradeStatistics.fromMarks([]),
    );
    final semesters = <int, GradeBookSemesterViewModel>{
      if (summary != null)
        for (final semester in summary.semesters)
          semester.number: GradeBookSemesterViewModel.grades(
            GradeSemesterViewModel(
              semester: semester,
              overall: summary.overall,
            ),
          ),
      for (final semester in plannedSemesters) semester.number: semester,
    };
    final numbers = semesters.keys.toList()..sort();
    _semesters = List.unmodifiable(numbers.map((number) => semesters[number]!));
    _hasGradeBook = summary != null || plannedSemesters.isNotEmpty;
    if (selectedSemesterIndex < 0) {
      _selectedSemesterNumber = plannedSemesters.isNotEmpty
          ? plannedSemesters.first.number
          : _semesters.isEmpty
              ? null
              : _semesters.last.number;
    }
  }

  List<GradeBookSemesterViewModel> _plannedSemesters(
    Map<int, CurriculumSemester> curriculum,
    Map<int, List<MarkBySubject>> marks,
    GradeStatistics overall,
  ) {
    if (curriculum.isEmpty) {
      return const [];
    }
    final numbers = curriculum.keys.where((number) => number > 0).toList()
      ..sort();
    if (numbers.isEmpty) {
      return const [];
    }
    final profile = _userStorage.currentUserData;
    final profileCourse =
        profile is StudentData ? profile.baseEduInfo.eduCourse : null;
    final course = profileCourse != null && profileCourse > 0
        ? profileCourse
        : (numbers.first + 1) ~/ 2;
    final current = AcademicYear.semesterForCourse(course, _currentTime());
    return [
      for (final number in [current, if (current.isOdd) current + 1])
        if (curriculum[number] case final CurriculumSemester semester)
          GradeBookSemesterViewModel.fromCurriculum(
            number: number,
            curriculum: semester,
            marks: marks[number] ?? const [],
            overall: overall,
          ),
    ];
  }

  Future<Map<int, List<MarkBySubject>>?> _getGradeBook() =>
      tryLoginAndRetrieveData(
        () async {
          final gradeBook = await _gradeBookService.getGradeBook();
          if (gradeBook != null) {
            await _markBySubjectProvider.saveData(gradeBook);
          }
          return gradeBook;
        },
        _markBySubjectProvider.getData,
      );
}
