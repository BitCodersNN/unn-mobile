import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class ExportScheduleService{
  Future<void> exportSchedule(ScheduleFilter scheduleFilter);
}
