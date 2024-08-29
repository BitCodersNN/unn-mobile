import 'package:unn_mobile/core/misc/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/models/mark_by_subject.dart';
import 'package:unn_mobile/core/services/interfaces/getting_grade_book.dart';
import 'package:unn_mobile/core/services/interfaces/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class GradesScreenViewModel extends BaseViewModel {
  final GettingGradeBook gradeBookService;
  final MarkBySubjectProvider markBySubjectProvider;

  GradesScreenViewModel(this.gradeBookService, this.markBySubjectProvider);

  Future<Map<int, List<MarkBySubject>>?> getGradeBook() async {
    return await tryLoginAndRetrieveData(
      () async {
        final gradeBook = await gradeBookService.getGradeBook();
        if (gradeBook != null) {
          markBySubjectProvider.saveData(gradeBook);
        }
        return gradeBook;
      },
      () async => markBySubjectProvider.getData(),
    );
  }
}
