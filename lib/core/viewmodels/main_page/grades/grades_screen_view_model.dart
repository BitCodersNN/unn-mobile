// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/models/grade_book/grade_book_summary.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/providers/interfaces/grade_book/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/services/interfaces/grade_book/grade_book_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grade_semester_view_model.dart';

class GradesScreenViewModel extends BaseViewModel {
  final GradeBookService _gradeBookService;
  final MarkBySubjectProvider _markBySubjectProvider;

  List<GradeSemesterViewModel> _semesters = const [];
  int? _selectedSemesterNumber;
  bool _hasGradeBook = false;
  bool _hasError = false;
  Future<void>? _pendingLoad;

  GradesScreenViewModel(this._gradeBookService, this._markBySubjectProvider);

  List<GradeSemesterViewModel> get semesters => _semesters;

  int? get selectedSemesterNumber => _selectedSemesterNumber;

  int get selectedSemesterIndex => _semesters.indexWhere(
        (model) => model.semester.number == _selectedSemesterNumber,
      );

  bool get hasGradeBook => _hasGradeBook;

  bool get hasError => _hasError;

  void selectSemester(int number) {
    if (disposed ||
        number == _selectedSemesterNumber ||
        !_semesters.any((model) => model.semester.number == number)) {
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
    if (disposed) {
      return;
    }
    final summary = book == null ? null : GradeBookSummary.fromGradeBook(book);
    _semesters = List.unmodifiable(
      summary?.semesters.map(
            (semester) => GradeSemesterViewModel(
              semester: semester,
              overall: summary.overall,
            ),
          ) ??
          <GradeSemesterViewModel>[],
    );
    _hasGradeBook = summary != null;
    if (selectedSemesterIndex < 0) {
      _selectedSemesterNumber =
          _semesters.isEmpty ? null : _semesters.last.semester.number;
    }
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
