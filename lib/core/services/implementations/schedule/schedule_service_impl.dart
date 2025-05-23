// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _QueryParameterKeys {
  static const String _start = 'start';
  static const String _finish = 'finish';
  static const String _lng = 'lng';
}

class ScheduleServiceImpl implements ScheduleService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  ScheduleServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List<Subject>?> getSchedule(ScheduleFilter scheduleFilter) async {
    final path =
        '${ApiPath.schedule}${scheduleFilter.idType.name}/${scheduleFilter.id}';

    Response response;
    try {
      response = await _apiHelper.get(
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
        options: OptionsWithExpectedTypeFactory.list,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    return parseJsonIterable<Subject>(
      response.data,
      Subject.fromJson,
      _loggerService,
    );
  }
}
