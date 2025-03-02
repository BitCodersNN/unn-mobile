import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/last_commit_sha.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class LastCommitShaServiceImpl implements LastCommitShaService {
  final _path = 'repos/${ApiPath.gitRepository}/commits/main?per_page=1';
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  LastCommitShaServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<String?> getSha() async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: _path,
        options: OptionsWithExpectedTypeFactory.jsonMap,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    String sha;
    try {
      sha = response.data['sha'];
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }
    return sha;
  }
}
