// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/requests/shared_request_pool.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';

class _QueryParameterKeys {
  static const String _start = 'start';
  static const String _finish = 'finish';
  static const String _lng = 'lng';
}

class _DataKeys {
  static const String _json = 'json';
  static const String _date = 'date';
  static const String _login = 'login';
}

class ScheduleServiceImpl implements ScheduleService {
  final LoggerService _loggerService;
  final ApiHelper _unnApiHelper;
  final ApiHelper _raspApiHelper;
  final _portalRequests =
      SharedRequestPool<
        ({IdType type, String id, DateTime start, DateTime end}),
        List<Subject>?
      >();
  final _raspRequests =
      SharedRequestPool<({String login, DateTime week}), List<Subject>?>();

  ScheduleServiceImpl(
    this._loggerService,
    this._unnApiHelper,
    this._raspApiHelper,
  );

  @override
  Future<List<Subject>?> getSchedule(
    ScheduleFilter scheduleFilter, {
    CancelToken? cancelToken,
  }) async {
    final range = scheduleFilter.dateTimeRange;
    final subjects = await _portalRequests.run(
      (
        type: scheduleFilter.idType,
        id: scheduleFilter.id,
        start: DateTime(range.start.year, range.start.month, range.start.day),
        end: DateTime(range.end.year, range.end.month, range.end.day),
      ),
      (token) => _loadPortalSchedule(scheduleFilter, token),
      cancelToken: cancelToken,
    );
    return subjects == null ? null : List<Subject>.of(subjects);
  }

  Future<List<Subject>?> _loadPortalSchedule(
    ScheduleFilter scheduleFilter,
    CancelToken cancelToken,
  ) async {
    final path =
        '${ApiPath.schedule}${scheduleFilter.idType.name}/${scheduleFilter.id}';

    Response response;
    try {
      response = await _unnApiHelper.get(
        path: path,
        queryParameters: {
          _QueryParameterKeys._start: scheduleFilter.dateTimeRange.start
              .toIso8601String()
              .split('T')[0]
              .replaceAll('-', '.'),
          _QueryParameterKeys._finish: scheduleFilter.dateTimeRange.end
              .toIso8601String()
              .split('T')[0]
              .replaceAll('-', '.'),
          _QueryParameterKeys._lng: '1',
        },
        cancelToken: cancelToken,
        options: OptionsWithExpectedTypeFactory.list,
      );
    } catch (error, stackTrace) {
      if (error is DioException && CancelToken.isCancel(error)) {
        rethrow;
      }
      _loggerService.logError(error, stackTrace);
      return null;
    }

    return parseJsonIterable<Subject>(
      response.data,
      Subject.fromJson,
      _loggerService,
    );
  }

  @override
  Future<List<Subject>?> getCurrentUserSchedule(
    String login,
    DateTime date, {
    CancelToken? cancelToken,
  }) async {
    final week = WeekRange(weekOffset: 0, reference: date);
    final subjects = await _raspRequests.run(
      (login: login, week: week.start),
      (token) => _loadRaspSchedule(login, week.start, token),
      cancelToken: cancelToken,
    );
    return subjects == null ? null : List<Subject>.of(subjects);
  }

  Future<List<Subject>?> _loadRaspSchedule(
    String login,
    DateTime date,
    CancelToken cancelToken,
  ) async {
    Response response;
    try {
      response = await _raspApiHelper.post(
        path: ApiPath.raspSchedule,
        data: {
          _DataKeys._json: _DataKeys._json,
          _DataKeys._date: DateTimeParser.format(
            date,
            DatePattern.yyyymmddDash,
          ),
          _DataKeys._login: login,
        },
        cancelToken: cancelToken,
        options: OptionsWithExpectedTypeFactory.jsonMap,
      );
    } catch (error, stackTrace) {
      if (error is DioException && CancelToken.isCancel(error)) {
        rethrow;
      }
      _loggerService.logError(error, stackTrace);
      return null;
    }
    return parseJsonIterable<Subject>(
      (response.data as Map)['Schedule'],
      Subject.fromRaspJson,
      _loggerService,
    );
  }
}
