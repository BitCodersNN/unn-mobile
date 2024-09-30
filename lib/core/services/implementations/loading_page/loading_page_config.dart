import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/loading_page_data.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_config.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class LoadingPageConfigServiceImpl implements LoadingPageConfigService {
  final _path = '${ApiPaths.gitRepository}/main/loading_page_config.json';
  final LoggerService _loggerService;

  LoadingPageConfigServiceImpl(this._loggerService);

  @override
  Future<List<LoadingPageModel>?> getLoadingPages() async {
    final requestSender = HttpRequestSender(
      host: ApiPaths.gitHubHost,
      path: _path,
    );

    HttpClientResponse response;
    try {
      response = await requestSender.get();
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      _loggerService.log(
        'statusCode = $statusCode;',
      );
      return null;
    }

    Map<String, dynamic> jsonMap;

    try {
      jsonMap =
          jsonDecode(await HttpRequestSender.responseToStringBody(response));
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
