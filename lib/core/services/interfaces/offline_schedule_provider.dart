import 'package:unn_mobile/core/models/subject.dart';

abstract interface class OfflineScheduleProvider{
  Future<List<Subject>?> loadSchedule();
  Future<void> saveSchedule(List<Subject> schedule);
}
