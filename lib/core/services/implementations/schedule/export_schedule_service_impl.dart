// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:device_calendar/device_calendar.dart';
import 'package:dio/dio.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/export_schedule_service.dart';

class ExportScheduleServiceImpl implements ExportScheduleService {
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
        '${ApiPath.schedule}${scheduleFilter.idType.name}/${scheduleFilter.id}.$_ics';

    Response response;
    try {
      response = await _apiHelper.get(
        path: path,
        queryParameters: {
          _start: scheduleFilter.dateTimeRange.start.format(
            DatePattern.yyyymmddDot,
          ),
          _finish: scheduleFilter.dateTimeRange.end.format(
            DatePattern.yyyymmddDot,
          ),
          _lng: '1',
        },
        options: OptionsWithExpectedTypeFactory.string,
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

    final iCalendarData =
        ICalendar.fromString(response.data).data.skip(1).toList();

    final deviceCalendarPlugin = DeviceCalendarPlugin();

    final isGranted = await PermissionHandlerPlatform.instance
        .checkPermissionStatus(Permission.calendarFullAccess)
        .isGranted;

    if (!isGranted) {
      return ExportScheduleResult.noPermission;
    }

    String? calendarID = await _findCalendarId(deviceCalendarPlugin);

    calendarID ??=
        (await deviceCalendarPlugin.createCalendar(_calendarName)).data;

    return _addEventsInCalendar(
      deviceCalendarPlugin,
      iCalendarData,
      calendarID,
    );
  }

  @override
  Future<RequestCalendarPermissionResult> requestCalendarPermission() async {
    final status = await PermissionHandlerPlatform.instance
        .checkPermissionStatus(Permission.calendarFullAccess);

    if (status.isDenied) {
      final permissionStatuses = await PermissionHandlerPlatform.instance
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
  Future<bool> openSettings() =>
      PermissionHandlerPlatform.instance.openAppSettings();

  Future<String?> _findCalendarId(
    DeviceCalendarPlugin deviceCalendarPlugin,
  ) async {
    final calendars = await deviceCalendarPlugin.retrieveCalendars();

    for (final calendar in calendars.data!) {
      if (calendar.name == _calendarName) {
        return calendar.id;
      }
    }

    return null;
  }

  Future<ExportScheduleResult> _addEventsInCalendar(
    DeviceCalendarPlugin deviceCalendarPlugin,
    List<Map<String, dynamic>> iCalendarData,
    String? calendarID,
  ) async {
    const String summary = 'summary';
    const String location = 'location';
    const String dtstart = 'dtstart';
    const String dtend = 'dtend';
    const String description = 'description';

    final timeZone = timeZoneDatabase.locations[_timeZone];
    if (timeZone == null) {
      throw StateError('Часовой пояс $_timeZone не поддерживается');
    }

    final futures = iCalendarData.map((event) {
      final start = event[dtstart] as IcsDateTime?;
      final end = event[dtend] as IcsDateTime?;

      if (start?.dt == null || end?.dt == null) {
        throw Exception('Пропущено время начала или окончания события: $event');
      }

      return deviceCalendarPlugin.createOrUpdateEvent(
        Event(
          calendarID,
          title: event[summary] as String?,
          location: event[location] as String?,
          description: event[description] as String?,
          start: TZDateTime.parse(timeZone, start!.dt),
          end: TZDateTime.parse(timeZone, end!.dt),
        ),
      );
    }).toList();

    try {
      await Future.wait(futures, eagerError: true);
    } catch (e) {
      rethrow;
    }

    return ExportScheduleResult.success;
  }
}
