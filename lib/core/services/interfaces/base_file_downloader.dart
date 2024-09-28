import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/file_functions.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/services/interfaces/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

abstract class BaseFileDownloaderService implements FileDownloaderService {
  final LoggerService _loggerService;
  final String? _host;
  final String? _path;
  Map<String, String> _cookies;

  BaseFileDownloaderService(
    this._loggerService, {
    String? host,
    String? path,
    Map<String, String> cookies = const {},
  })  : _host = host,
        _path = path,
        _cookies = cookies;

  @protected
  void updateCookies(Map<String, String> newCookies) {
    _cookies = newCookies;
  }

  @override
  Future<File?> downloadFile(
    String filePath, {
    String? downloadUrl,
    bool force = false,
  }) async {
    assert(_host != null && _path != null || downloadUrl != null);

    final String? downloadsPath = await getDownloadPath();
    if (downloadsPath == null) {
      _loggerService.log('Download path is null');
      return null;
    }

    final storedFile = File('$downloadsPath/$filePath');

    if (!force && await storedFile.exists()) {
      return storedFile;
    }

    await storedFile.parent.create(recursive: true);
    String host = _host ?? '';
    String path = '$_path/$filePath';
    Map<String, dynamic> queryParams = {};
    if (downloadUrl != null) {
      final uri = Uri.parse(downloadUrl);
      host = uri.host;
      path = uri.path;
      queryParams = uri.queryParameters;
    }
    final requestSender = HttpRequestSender(
      host: host,
      path: path,
      queryParams: queryParams,
      cookies: _cookies,
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

    Uint8List bytes;
    try {
      bytes = await consolidateHttpClientResponseBytes(response);
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    try {
      await storedFile.writeAsBytes(bytes);
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    return storedFile;
  }

  @override
  Future<List<File>?> downloadFiles(List<String> filePaths) async {
    final futures = <Future>[];

    for (final filePath in filePaths) {
      futures.add(downloadFile(filePath));
    }

    final data = await Future.wait(futures);
    final fileList = data.map((dynamic item) => item as File).toList();

    return fileList;
  }
}
