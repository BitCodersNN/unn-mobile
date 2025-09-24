// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/camel_case_converter.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/models/profile/employee/preview_employee.dart';
import 'package:unn_mobile/core/models/profile/student/preview_student.dart';
import 'package:unn_mobile/core/models/profile/search_filter.dart';
import 'package:unn_mobile/core/models/profile/sort_field.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_search_service.dart';

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

class ProfileSearchServiceImpl implements ProfileSearchService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  ProfileSearchServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<ResultWithTotal<PreviewEmployee>?> getEmployees(
    EmployeeSearchFilter searchFilter, {
    int ordinalNumberFirst = 0,
    int count = 10,
    bool reverse = false,
  }) async =>
      _fetchPaginatedData(
        ApiPath.employees,
        searchFilter,
        SortField.fullname,
        reverse,
        ordinalNumberFirst,
        count,
        PreviewEmployee.fromJson,
      );

  @override
  Future<ResultWithTotal<PreviewStudent>?> getStudents(
    SearchFilter searchFilter, {
    int ordinalNumberFirst = 0,
    int count = 10,
    SortField sortField = SortField.fullname,
    bool reverse = false,
  }) async =>
      _fetchPaginatedData(
        ApiPath.students,
        searchFilter,
        sortField,
        reverse,
        ordinalNumberFirst,
        count,
        PreviewStudent.fromJson,
      );

  Future<ResultWithTotal<T>?> _fetchPaginatedData<T>(
    String path,
    SearchFilter searchFilter,
    SortField sortField,
    bool reverse,
    int ordinalNumberFirst,
    int count,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: path,
        data: {
          _DataKeys.filters: searchFilter.filters,
          _DataKeys.first: ordinalNumberFirst,
          _DataKeys.rows: count,
          _DataKeys.globalFilter: searchFilter.globalFilter,
          _DataKeys.sortField: sortField.name.toSnakeCase(),
          _DataKeys.sortOrder: reverse ? 1 : -1,
        },
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }
    final items = parseJsonIterable<T>(
      response.data[_ResponseJsonKeys.items],
      fromJson,
      _loggerService,
    );

    return ResultWithTotal(
      items: items,
      total: response.data[_ResponseJsonKeys.total],
    );
  }
}
