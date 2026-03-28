import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/analytics_label.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_range_extensions.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/response_status_validator.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_search_service.dart';

class _QueryParameters {
  static const String mode = 'mode';
  static const String ajax = 'ajax';
}

class _DataKeys {
  static const String paramsFilterId = 'params[FILTER_ID]';
  static const String paramsGridId = 'params[GRID_ID]';
  static const String paramsAction = 'params[action]';
  static const String paramsForAll = 'params[forAll]';
  static const String paramsApplyFilter = 'params[apply_filter]';
  static const String paramsClearFilter = 'params[clear_filter]';
  static const String paramsWithPreset = 'params[with_preset]';
  static const String paramsSave = 'params[save]';
  static const String paramsIsSetOutside = 'params[isSetOutside]';
  static const String dataFieldsFind = 'data[fields][FIND]';
  static const String dataFieldsDateCreateDatesel =
      'data[fields][DATE_CREATE_datesel]';
  static const String dataFieldsDateCreateFrom =
      'data[fields][DATE_CREATE_from]';
  static const String dataFieldsDateCreateTo = 'data[fields][DATE_CREATE_to]';
  static const String dataFieldsDateCreateDays =
      'data[fields][DATE_CREATE_days]';
  static const String dataFieldsDateCreateMonth =
      'data[fields][DATE_CREATE_month]';
  static const String dataFieldsDateCreateQuarter =
      'data[fields][DATE_CREATE_quarter]';
  static const String dataFieldsDateCreateYear =
      'data[fields][DATE_CREATE_year]';
  static const String dataFieldsCreatedById = 'data[fields][CREATED_BY_ID]';
  static const String dataFieldsCreatedByIdLabel =
      'data[fields][CREATED_BY_ID_label]';
  static const String dataFieldsTo = 'data[fields][TO]';
  static const String dataFieldsToLabel = 'data[fields][TO_label]';
  static const String dataFieldsEventId0 = 'data[fields][EVENT_ID][0]';
  static const String dataRows = 'data[rows]';
  static const String dataPresetId = 'data[preset_id]';
  static const String dataName = 'data[name]';
}

class _DataValues {
  static const String liveFeed = 'LIVEFEED';
  static const String actionSetFilter = 'setFilter';
  static const String presetIdTmp = 'tmp_filter';
  static const String nameDeals = 'Дела';
  static const String flagYes = 'Y';
  static const String flagNo = 'N';
  static const String stringFalse = 'false';
  static const String dateSelNone = 'NONE';
  static const String dateSelRange = 'RANGE';
  static const String eventIdBlogPostImportant = 'blog_post_important';
  static const String empty = '';
  static const String rowsValue = 'DATE_CREATE,EVENT_ID,CREATED_BY_ID,TO';
}

class BlogPostSearchServiceImpl implements BlogPostSearchService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  BlogPostSearchServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<bool> resetFilter() => setFilter();

  @override
  Future<bool> setFilter({
    String query = '',
    bool onlyImportant = false,
    DateTimeRange? dateRange,
  }) async {
    final data = {
      _DataKeys.paramsFilterId: _DataValues.liveFeed,
      _DataKeys.paramsGridId: _DataValues.liveFeed,
      _DataKeys.paramsAction: _DataValues.actionSetFilter,
      _DataKeys.paramsForAll: _DataValues.stringFalse,
      _DataKeys.paramsApplyFilter: _DataValues.flagNo,
      _DataKeys.paramsClearFilter: _DataValues.flagYes,
      _DataKeys.paramsWithPreset: _DataValues.flagNo,
      _DataKeys.paramsSave: _DataValues.flagYes,
      _DataKeys.paramsIsSetOutside: _DataValues.stringFalse,
      _DataKeys.dataFieldsFind: query,
      _DataKeys.dataFieldsDateCreateDatesel: dateRange == null
          ? _DataValues.dateSelNone
          : _DataValues.dateSelRange,
      _DataKeys.dataFieldsDateCreateFrom:
          dateRange.formatStart(pattern: DatePattern.ddmmyyyy),
      _DataKeys.dataFieldsDateCreateTo:
          dateRange.formatEnd(pattern: DatePattern.ddmmyyyy),
      _DataKeys.dataFieldsDateCreateDays: _DataValues.empty,
      _DataKeys.dataFieldsDateCreateMonth: _DataValues.empty,
      _DataKeys.dataFieldsDateCreateQuarter: _DataValues.empty,
      _DataKeys.dataFieldsDateCreateYear: _DataValues.empty,
      _DataKeys.dataFieldsCreatedById: _DataValues.empty,
      _DataKeys.dataFieldsCreatedByIdLabel: _DataValues.empty,
      _DataKeys.dataFieldsTo: _DataValues.empty,
      _DataKeys.dataFieldsToLabel: _DataValues.empty,
      _DataKeys.dataRows: _DataValues.rowsValue,
      _DataKeys.dataPresetId: _DataValues.presetIdTmp,
      _DataKeys.dataName: _DataValues.nameDeals,
    };

    if (onlyImportant) {
      data.putIfAbsent(
        _DataKeys.dataFieldsEventId0,
        () => _DataValues.eventIdBlogPostImportant,
      );
    }

    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AnalyticsLabel.filterId: AnalyticsLabel.liveFeed,
          AnalyticsLabel.gridId: AnalyticsLabel.liveFeed,
          AnalyticsLabel.presetId: AnalyticsLabel.tmpFilter,
          AnalyticsLabel.find: AnalyticsLabel.yes,
          AnalyticsLabel.rows: AnalyticsLabel.no,
          _QueryParameters.mode: _QueryParameters.ajax,
          AjaxActionStrings.actionKey: AjaxActionStrings.setFilter,
          AjaxActionStrings.c: AjaxActionStrings.filter,
        },
        data: data,
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          30,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return false;
    }

    return ResponseStatusValidator.validate(response.data, _loggerService);
  }
}
