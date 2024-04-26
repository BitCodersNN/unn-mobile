import 'package:unn_mobile/core/models/schedule_filter.dart';

enum ExportScheduleResult {
  success,
  noPermission,
  timeout,
  statusCodeIsntOk,
}

enum RequestCalendarPermissionResult {
  allowed,
  rejected,
  permanentlyDenied,
}

abstract interface class ExportScheduleService {
  /// Экспортирует расписание в дефолтный календарь устройства
  ///
  /// Перед вызовом необходимо вызвать [requestCalendarPermission] и убедиться, что разрешение на использование календаря есть
  ///
  /// [scheduleFilter]: Фильтр, по которому происходит получение расписания
  ///
  /// Выбрасывает исключение:
  ///  1. [Exception] - если возникло непредвиденное исключение
  ///
  /// Возвращает [ExportScheduleResult]
  Future<ExportScheduleResult> exportSchedule(ScheduleFilter scheduleFilter);

  /// Запрашивает  разрешение на использование календаря
  ///
  /// Возвращает [RequestCalendarPermissionResult]:
  /// - [RequestCalendarPermissionResult.allowed] - если есть разрешение, или пользователь только что его предоставил
  /// - [RequestCalendarPermissionResult.rejected] - если пользователь не предоставил разрешение в всплывающем окне
  /// - [RequestCalendarPermissionResult.permanentlyDenied] - если пользователь ранее запретил редактирование календаря
  Future<RequestCalendarPermissionResult> requestCalendarPermission();

  /// Открывает настройки приложения
  ///
  /// Возвращает [true], если можно открыть страницу настроек приложения, в противном случае [false]
  Future<bool> openSettings();
}
