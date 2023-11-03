import 'dart:io';
import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class ExportScheduleService{
  Future<File> exportSchedule(String id, ScheduleFilter scheduleFilter);
  Future<void> requestCalendarPermission();
}
