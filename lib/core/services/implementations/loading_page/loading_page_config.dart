import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_api_helper.dart';
import 'package:unn_mobile/core/models/loading_page_data.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_config.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class LoadingPageConfigServiceImpl implements LoadingPageConfigService {
  final _path = '${ApiPaths.gitRepository}/main/loading_page_config.json';
  final LoggerService _loggerService;
  final BaseApiHelper _baseApiHelper;

  LoadingPageConfigServiceImpl(
    this._loggerService,
    this._baseApiHelper,
  );

  @override
  Future<List<LoadingPageModel>?> getLoadingPages() async {
    Response response;
    try {
      response = await _baseApiHelper.get(path: _path);
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    Map<String, dynamic> jsonMap;

    try {
      jsonMap = jsonDecode(response.data);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final List<LoadingPageModel> loadingPages = [];

    for (final loadingPagesJsonList in jsonMap.values) {
      for (final loadingPageJson in loadingPagesJsonList) {
        loadingPages.add(LoadingPageModel.fromJson(loadingPageJson));
      }
    }

    return loadingPages;
  }
}
