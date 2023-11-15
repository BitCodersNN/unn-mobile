import 'dart:developer';
import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/export_schedule_service.dart';

class ExportScheduleServiceImpl implements ExportScheduleService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  final String _calendarName = 'Расписание ННГУ';
  final String _ics = 'ics';
  final String _start = 'start';
  final String _finish = 'finish';
  final String _lng = '1';
  final String _timeZone = 'Europe/Moscow';
  String _path = 'ruzapi/schedule/';

  int? _statusCode;

  int? get statusCode => _statusCode;

  @override
  Future<ExportScheduleResult> exportSchedule(
      ScheduleFilter scheduleFilter) async {
    _path = '$_path${scheduleFilter.idType.name}/${scheduleFilter.id}.$_ics';

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

    final iCalendarData = ICalendar.fromString(await HttpRequestSender.responseToStringBody(response)).data;
    iCalendarData.removeAt(0);

    if (!(await _requestCalendarPermission())){
      return ExportScheduleResult.noPermission;
    }

    String? calendarID = await _findCalendarId();
    calendarID ??= (await _deviceCalendarPlugin.createCalendar(_calendarName)).data;

    return _addEventsInCalendar(iCalendarData, calendarID);
  }

  Future<bool> _requestCalendarPermission() async {
    final status = await Permission.calendarFullAccess.status;
    if (status.isDenied) {
      return (await Permission.calendar.request()).isGranted;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return (await Permission.calendarFullAccess.status).isGranted;
    }

    return true;
  }

  Future<String?> _findCalendarId() async{
    final calendars = await _deviceCalendarPlugin.retrieveCalendars();
    for (final calendar in calendars.data!){
      if (calendar.name == _calendarName){
        return calendar.id;
      }
    }
    return null;
  }

  Future<ExportScheduleResult> _addEventsInCalendar(iCalendarData, calendarID) async{
    const String summary = 'summary';
    const String location = 'location';
    const String dtstart = 'dtstart';
    const String dtend = 'dtend';
    const String description = 'description';

    final timeZone = timeZoneDatabase.locations[_timeZone]!;
    try {
      for (final event in iCalendarData){
        await _deviceCalendarPlugin.createOrUpdateEvent(Event(
          calendarID,
          title: event[summary],
          location: event[location],
          start: TZDateTime.parse(timeZone, (event[dtstart] as IcsDateTime).dt),
          end: TZDateTime.parse(timeZone, (event[dtend] as IcsDateTime).dt),
          description: event[description],
          ));
      }
    } catch (e){
      log(e.toString());
      return ExportScheduleResult.unknownError;
    }
    return ExportScheduleResult.success;
  }
}