import 'dart:io';
import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class DownloadingScheduleService{
  Future<File> downloadSchedule(String id, ScheduleFilter scheduleFilter);
}
