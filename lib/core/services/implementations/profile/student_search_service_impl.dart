// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/case_converter.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/models/profile/preview_student.dart';
import 'package:unn_mobile/core/models/profile/search_filter.dart';
import 'package:unn_mobile/core/models/profile/sort_field.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/student_search_service.dart';

class _DataKeys {
  static const String filters = 'filters';
  static const String first = 'first';
  static const String rows = 'rows';
  static const String globalFilter = 'globalFilter';
  static const String sortField = 'sortField';
  static const String sortOrder = 'sortOrder';
}

class _ResponseJsonKeys {
  static const String items = 'items';
  static const String total = 'total';
}

class StudentSearchServiceImpl implements StudentSearchService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  StudentSearchServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<ResultWithTotal<PreviewStudent>?> getStudents(
    SearchFilter searchFilter, {
    int ordinalNumberFirst = 0,
    int count = 10,
    SortField sortField = SortField.fullname,
    bool reverse = false,
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.students,
        data: {
          _DataKeys.filters: searchFilter.filters,
          _DataKeys.first: ordinalNumberFirst,
          _DataKeys.rows: count,
          _DataKeys.globalFilter: searchFilter.globalFilter,
          _DataKeys.sortField: camelToSnake(sortField.name),
          _DataKeys.sortOrder: reverse ? 1 : 0,
        },
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    final students = parseJsonIterable<PreviewStudent>(
      response.data[_ResponseJsonKeys.items],
      PreviewStudent.fromJson,
      _loggerService,
    );

    return ResultWithTotal(
      items: students,
      total: response.data[_ResponseJsonKeys.total],
    );
  }
}
