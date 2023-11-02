import 'package:unn_mobile/core/models/subject.dart';

abstract interface class ScheduleProvider{
  Future<List<Subject>> getSubjects();
  Future<void> saveSchedule(List<Subject> schedule);
}
