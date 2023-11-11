import 'package:unn_mobile/core/models/schedule_filter.dart';

enum ExportScheduleResult {
  success,
  noPermission,
  timeout,
  statusCodeIsntOk,
  unknownError,
}

abstract interface class ExportScheduleService{
  /// Экспортирует расписание в дефолтный календарь устройства
  /// 
  /// [scheduleFilter]: Фильтр, по которому происходит получение расписания
  /// 
  /// Возращает [ExportScheduleResult]
  Future<ExportScheduleResult> exportSchedule(ScheduleFilter scheduleFilter);
}
