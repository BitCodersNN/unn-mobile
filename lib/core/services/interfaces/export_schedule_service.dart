import 'package:unn_mobile/core/models/schedule_filter.dart';

enum ExportScheduleResult {
  success,
  noPermission,
  timeout,
  statusCodeIsntOk,
  unknownError,
}

enum RequestCalendarPermissionResult {
  allowed,
  rejected,
  permanentlyDenied,
}

abstract interface class ExportScheduleService{
  /// Экспортирует расписание в дефолтный календарь устройства
  /// 
  /// Перед вызовом необходимо вызвать [requestCalendarPermission] и убедиться, что разрешение на использование календаря есть
  /// 
  /// [scheduleFilter]: Фильтр, по которому происходит получение расписания
  /// 
  /// Возращает [ExportScheduleResult]
  Future<ExportScheduleResult> exportSchedule(ScheduleFilter scheduleFilter);

  /// Запршивает  разрешение на использование календаря
  /// 
  /// Возращает [RequestCalendarPermissionResult]:
  /// - [RequestCalendarPermissionResult.allowed] - если есть разрешение, или пользователь только что его предоставил
  /// - [RequestCalendarPermissionResult.rejected] - если пользователь не предоставил разрешение в сплывающем окне
  /// - [RequestCalendarPermissionResult.permanentlyDenied] - если пользователь ранее не разрешил редактирование календаря
  Future<RequestCalendarPermissionResult> requestCalendarPermission();

  /// Открывает настроки приложения
  /// 
  /// Возвращает [true], если можно открыть страницу настроек приложения, в противном случае [false]
  Future<bool> openSettings();
}
