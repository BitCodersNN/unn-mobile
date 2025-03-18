import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/services/interfaces/grade_book/grade_book_service.dart';
import 'package:unn_mobile/core/providers/interfaces/grade_book/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class GradesScreenViewModel extends BaseViewModel {
  final GradeBookService _gradeBookService;
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
