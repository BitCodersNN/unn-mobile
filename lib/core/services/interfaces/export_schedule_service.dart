import 'package:unn_mobile/core/models/schedule_filter.dart';

enum ExportScheduleResult {
  success,
  noPermission,
  timeout,
  statusCodeIsntOk,
  unknownError,
}

abstract interface class ExportScheduleService{
  Future<ExportScheduleResult> exportSchedule(ScheduleFilter scheduleFilter);
}
