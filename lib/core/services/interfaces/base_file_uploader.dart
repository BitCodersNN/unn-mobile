import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/file_functions.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/services/interfaces/file_uploader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

abstract class BaseFileUploader implements FileUploader {
  final LoggerService _loggerService;
  final String _host;
  final String _path;
  final Map<String, String> _cookies;

  BaseFileUploader(
    this._loggerService,
    this._host, {
    String path = '',
    Map<String, String> cookies = const {},
  })  : _path = path,
        _cookies = cookies;

  @override
  Future<File?> downloadFile(String filePath) async {
    final String? downloadsPath = await getDownloadPath();
    if (downloadsPath == null) {
      _loggerService.log('Download path is null');
      return null;
    }

    final storedFile = File('$downloadsPath/$filePath');

    await storedFile.parent.create(recursive: true);

    final requestSender = HttpRequestSender(
      host: _host,
      path: '$_path/$filePath',
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
