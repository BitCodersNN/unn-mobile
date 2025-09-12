// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/api/request_payload.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/response_status_validator.dart';
import 'package:unn_mobile/core/models/dialog/preview_dialog.dart';
import 'package:unn_mobile/core/models/dialog/preview_group_dialog.dart';
import 'package:unn_mobile/core/models/dialog/preview_user_dialog.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/dialog_search_service.dart';

class _DataKeys {
  static const String dialog = 'dialog';
  static const String searchQuery = 'searchQuery';
  static const String query = 'query';
  static const String queryWords = 'queryWords';
  static const String recentItems = 'recentItems';
  static const String id = 'id';
  static const String entityId = 'entityId';
}

class _ResponseJsonKeys {
  static const String data = 'data';
  static const String dialog = 'dialog';
  static const String items = 'items';
  static const String entityType = 'entityType';
  static const String chat = 'im-chat';
  static const String user = 'im-user';
  static const String imRecentV2 = 'im-recent-v2';
}

class DialogSearchServiceImpl implements DialogSearchService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  DialogSearchServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List<PreviewDialog>?> getHistory() async => _fetchDialogs(
        {
          AjaxActionStrings.actionKey: AjaxActionStrings.loadDialog,
        },
      );

  @override
  Future<List<PreviewDialog>?> search(String query) async => _fetchDialogs(
        {
          AjaxActionStrings.actionKey: AjaxActionStrings.searchDialog,
        },
        data: {
          _DataKeys.searchQuery: {
            _DataKeys.query: query.toLowerCase(),
            _DataKeys.queryWords: query.toLowerCase().split(' '),
          },
        },
      );

  @override
  Future<bool> save(List<String> dialogIds) async {
    final responseData = await _executeQuery(
      {
        AjaxActionStrings.actionKey: AjaxActionStrings.saveDialog,
      },
      data: {
        _DataKeys.dialog: RequestPayload.dialog,
        _DataKeys.recentItems: dialogIds
            .map(
              (id) => {
                _DataKeys.id: id,
                _DataKeys.entityId: _ResponseJsonKeys.imRecentV2,
              },
            )
            .toList(),
      },
    );
    if (responseData == null) return false;

    return ResponseStatusValidator.validate(responseData, _loggerService);
  }

  Future<List<PreviewDialog>?> _fetchDialogs(
    Map<String, dynamic> queryParameters, {
    Map<String, dynamic>? data,
  }) async {
    final responseData = await _executeQuery(queryParameters, data: data);

    if (responseData == null) return null;

    return parseJsonIterable<PreviewDialog>(
      responseData[_ResponseJsonKeys.data][_ResponseJsonKeys.dialog]
          [_ResponseJsonKeys.items],
      (json) {
        final type = json[_ResponseJsonKeys.entityType] as String;
        switch (type) {
          case _ResponseJsonKeys.chat:
            return PreviewGroupDialog.fromJson(json);
          case _ResponseJsonKeys.user:
            return PreviewUserDialog.fromJson(json);
          default:
            throw FormatException('Unknown dialog type: $type');
        }
      },
      _loggerService,
    );
  }

  Future<dynamic> _executeQuery(
    Map<String, dynamic> queryParameters, {
    Map<String, dynamic>? data,
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: queryParameters,
        data: {
          _DataKeys.dialog: RequestPayload.dialog,
          ...?data,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.jsonMap,
          contentTypeHeader: Headers.jsonContentType,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    return response.data;
  }
}
