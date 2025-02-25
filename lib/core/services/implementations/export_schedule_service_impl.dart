import 'package:device_calendar/device_calendar.dart';
import 'package:dio/dio.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/date_time_extensions.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/export_schedule_service.dart';

class ExportScheduleServiceImpl implements ExportScheduleService {
  final PermissionHandlerPlatform _permissionHandler =
      PermissionHandlerPlatform.instance;
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  final String _calendarName = 'Расписание ННГУ';
  final String _ics = 'ics';
  final String _start = 'start';
  final String _finish = 'finish';
  final String _lng = 'lng';
  final String _timeZone = 'Europe/Moscow';

  final ApiHelper _apiHelper;

  ExportScheduleServiceImpl(this._apiHelper);

  @override
  Future<ExportScheduleResult> exportSchedule(
    ScheduleFilter scheduleFilter,
  ) async {
    final path =
        '${ApiPaths.schedule}${scheduleFilter.idType.name}/${scheduleFilter.id}.$_ics';

    Response response;
    try {
      response = await _apiHelper.get(
        path: path,
        queryParameters: {
          _start: scheduleFilter.dateTimeRange.start.toFormattedDateString(),
          _finish: scheduleFilter.dateTimeRange.end.toFormattedDateString(),
          _lng: '1',
        },
      );
    } on DioException catch (exc) {
      switch (exc.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return ExportScheduleResult.timeout;
        case DioExceptionType.badCertificate:
        case DioExceptionType.cancel:
        case DioExceptionType.unknown:
          rethrow;
        case DioExceptionType.badResponse:
          return ExportScheduleResult.statusCodeIsntOk;
      }
    }

    final iCalendarData = ICalendar.fromString(
      response.data,
    ).data;
    iCalendarData.removeAt(0);

    final status = await _permissionHandler
        .checkPermissionStatus(Permission.calendarFullAccess);
    if (!status.isGranted) {
      return ExportScheduleResult.noPermission;
    }

    String? calendarID = await _findCalendarId();
    calendarID ??=
        (await _deviceCalendarPlugin.createCalendar(_calendarName)).data;

    return _addEventsInCalendar(iCalendarData, calendarID);
  }

  @override
  Future<RequestCalendarPermissionResult> requestCalendarPermission() async {
    final status = await _permissionHandler
        .checkPermissionStatus(Permission.calendarFullAccess);
    if (status.isDenied) {
      final permissionStatuses = await _permissionHandler
          .requestPermissions([Permission.calendarFullAccess]);
      return (permissionStatuses[Permission.calendarFullAccess] ==
              PermissionStatus.granted)
          ? RequestCalendarPermissionResult.allowed
          : RequestCalendarPermissionResult.rejected;
    } else if (status.isPermanentlyDenied) {
      return RequestCalendarPermissionResult.permanentlyDenied;
    }
    return RequestCalendarPermissionResult.allowed;
  }

  @override
  Future<bool> openSettings() {
    return _permissionHandler.openAppSettings();
  }

  Future<String?> _findCalendarId() async {
    final calendars = await _deviceCalendarPlugin.retrieveCalendars();
    for (final calendar in calendars.data!) {
      if (calendar.name == _calendarName) {
        return calendar.id;
      }
    }
    return null;
  }

  Future<ExportScheduleResult> _addEventsInCalendar(
    iCalendarData,
    calendarID,
  ) async {
    const String summary = 'summary';
    const String location = 'location';
    const String dtstart = 'dtstart';
    const String dtend = 'dtend';
    const String description = 'description';

    final timeZone = timeZoneDatabase.locations[_timeZone]!;
    try {
      for (final event in iCalendarData) {
        await _deviceCalendarPlugin.createOrUpdateEvent(
          Event(
            calendarID,
            title: event[summary],
            location: event[location],
            start:
                TZDateTime.parse(timeZone, (event[dtstart] as IcsDateTime).dt),
            end: TZDateTime.parse(timeZone, (event[dtend] as IcsDateTime).dt),
            description: event[description],
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
    return ExportScheduleResult.success;
  }
}
