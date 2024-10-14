part of 'package:unn_mobile/core/viewmodels/library.dart';

class GradesScreenViewModel extends BaseViewModel {
  final GettingGradeBook _gradeBookService;
  final MarkBySubjectProvider _markBySubjectProvider;

  GradesScreenViewModel(this._gradeBookService, this._markBySubjectProvider);

  Future<Map<int, List<MarkBySubject>>?> getGradeBook() async {
    return await tryLoginAndRetrieveData(
      () async {
        final gradeBook = await _gradeBookService.getGradeBook();
        if (gradeBook != null) {
          _markBySubjectProvider.saveData(gradeBook);
        }
        return gradeBook;
      },
      () async => _markBySubjectProvider.getData(),
    );
  }
}
