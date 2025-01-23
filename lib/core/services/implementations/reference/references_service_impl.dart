import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/models/reference_order/references.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/reference/references.dart';

class ReferencesServiceImpl implements ReferencesService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  ReferencesServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<References?> getReferences() async {
    Response response;

    try {
      response = await _apiHelper.get(
        path: ApiPaths.spravka,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }
    final jsonMap = jsonDecode(response.data);
    if (!jsonMap['enabled']) {
      return References.empty();
    }

    return References.fromJson(jsonMap);
  }
}
