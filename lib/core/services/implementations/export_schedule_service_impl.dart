import 'dart:developer';
import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/export_schedule_service.dart';

class ExportScheduleServiceImpl implements ExportScheduleService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  final String ics = 'ics';
  final String _start = 'start';
  final String _finish = 'finish';
  final String _lng = '1';
  String _path = 'ruzapi/schedule/';

  int? _statusCode;

  int? get statusCode => _statusCode;

  @override
  Future<ExportScheduleResult> exportSchedule(
      ScheduleFilter scheduleFilter) async {
    _path = '$_path${scheduleFilter.idType.name}/${scheduleFilter.id}.$ics';

    final requstSender = HttpRequestSender(path: _path, queryParams: {
      _start: scheduleFilter.dateTimeRange.start
          .toIso8601String()
          .split('T')[0]
          .replaceAll('-', '.'),
      _finish: scheduleFilter.dateTimeRange.end
          .toIso8601String()
          .split('T')[0]
          .replaceAll('-', '.'),
      _lng: '1',
    });

    HttpClientResponse response;
    try {
      response = await requstSender.get();
    } on TimeoutException {
      return ExportScheduleResult.timeout;
    } catch (e) {
      log(e.toString());
      return ExportScheduleResult.unknownError;
    }

    _statusCode = response.statusCode;

    if (_statusCode != 200) {
      return ExportScheduleResult.statusCodeIsntOk;
    }

    
    final hasPermissions = await _deviceCalendarPlugin.hasPermissions();

    if (!(hasPermissions.data as bool)) {
      final permissionResult = await _deviceCalendarPlugin.requestPermissions();
      if (!(permissionResult.data ?? false)) {
        return ExportScheduleResult.noPermission;
      }
    }

    final iCalendarData = ICalendar.fromString(await responseToStringBody(response)).data;
    iCalendarData.removeAt(0);

    final location = timeZoneDatabase.locations['Europe/Moscow']!;
    final calendars = await _deviceCalendarPlugin.retrieveCalendars();
    try {
      for (final event in iCalendarData){
        final ev = Event(
          calendars.data![0].id,
          title: event['summary'],
          start: TZDateTime.parse(location, (event['dtstart'] as IcsDateTime).dt),
          end: TZDateTime.parse(location, (event['dtend'] as IcsDateTime).dt),
          description: event['description'],
          );
        print(ev.start);
        await _deviceCalendarPlugin.createOrUpdateEvent(Event(
          calendars.data![0].id,
          title: event['summary'],
          start: TZDateTime.parse(location, (event['dtstart'] as IcsDateTime).dt),
          end: TZDateTime.parse(location, (event['dtend'] as IcsDateTime).dt),
          description: event['description'],
          ));
      }
    } catch (e){
      log(e.toString());
      return ExportScheduleResult.unknownError;
    }

    return ExportScheduleResult.success;
  }
}