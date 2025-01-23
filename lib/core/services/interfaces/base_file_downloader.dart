import 'dart:io';
import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/file_functions.dart';
import 'package:unn_mobile/core/services/interfaces/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:path/path.dart' as path;

abstract class BaseFileDownloaderService implements FileDownloaderService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;
  final String? _path;

  BaseFileDownloaderService(
    this._loggerService,
    this._apiHelper, {
    String? path,
    Map<String, String> cookies = const {},
  }) : _path = path;

  @override
  Future<File?> downloadFile(
    String filePath, {
    String? downloadUrl,
    bool force = false,
  }) async {
    final String? downloadsPath = await getDownloadPath();
    if (downloadsPath == null) {
      _loggerService.log('Download path is null');
      return null;
    }

    final shortenedFileName = shortenFileName(filePath);

    final storedFile = File('$downloadsPath/$shortenedFileName');

    if (!force && await storedFile.exists()) {
      return storedFile;
    }

    await storedFile.parent.create(recursive: true);
    String path = '$_path/$filePath';
    Map<String, dynamic> queryParams = {};

    if (_path == null) {
      path = '/$filePath';
    }

    if (downloadUrl != null && downloadUrl.isNotEmpty) {
      final uri = Uri.parse(downloadUrl);
      path = uri.path;
      queryParams = uri.queryParameters;
    }

    Response response;
    try {
      response = await _apiHelper.get(
        path: path,
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.bytes),
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    try {
      await storedFile.writeAsBytes(response.data);
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

  String shortenFileName(String fileName, [int maxFileNameLength = 127]) {
    final extension = path.extension(fileName);
    final baseName = path.basenameWithoutExtension(fileName);

    final shortenedBaseName = baseName.substring(
      0,
      baseName.length < maxFileNameLength
          ? baseName.length
          : maxFileNameLength - extension.length - 1,
    );
    return '$shortenedBaseName.$extension';
  }
}
