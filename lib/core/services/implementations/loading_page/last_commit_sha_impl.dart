part of '../library.dart';

class LastCommitShaServiceImpl implements LastCommitShaService {
  final _path = 'repos/${ApiPaths.gitRepository}/commits/main?per_page=1';
  final LoggerService _loggerService;

  LastCommitShaServiceImpl(this._loggerService);

  @override
  Future<String?> getSha() async {
    final requestSender = HttpRequestSender(
      host: ApiPaths.gitHubApiHost,
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

    return jsonMap['sha'];
  }
}
