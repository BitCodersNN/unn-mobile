import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/subject.dart';

abstract interface class GetScheduleService{
  Future<List<Subject>> getSchedule(ScheduleFilter scheduleFilter);
}
