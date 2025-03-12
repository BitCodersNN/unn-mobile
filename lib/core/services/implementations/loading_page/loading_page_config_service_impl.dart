import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_config_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class LoadingPageConfigServiceImpl implements LoadingPageConfigService {
  final _path = '${ApiPath.gitRepository}/main/loading_page_config.json';
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  LoadingPageConfigServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List<LoadingPageModel>?> getLoadingPages() async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: _path,
        options: OptionsWithExpectedTypeFactory.string,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    Map<String, dynamic> jsonMap;

    try {
      jsonMap = jsonDecode(response.data);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final loadingPages = jsonMap.values.expand((list) => list).toList();
    return parseJsonIterable<LoadingPageModel>(
      loadingPages,
      LoadingPageModel.fromJson,
      _loggerService,
    );
  }
}
