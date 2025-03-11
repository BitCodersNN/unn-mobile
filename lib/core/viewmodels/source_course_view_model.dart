import 'package:unn_mobile/core/models/distance_learning/distance_course.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/source_item_view_model.dart';

class SourceCourseViewModel extends BaseViewModel {
  final DistanceCourse _course;

  SourceCourseViewModel(DistanceCourse course) : _course = course;

  String get discipline => _course.discipline;

  Iterable<SourceItemViewModel> get items =>
      _course.materials.map((m) => SourceItemViewModel(m));
}
