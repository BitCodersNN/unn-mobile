import 'dart:io';
import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_api_helper.dart';
import 'package:unn_mobile/core/misc/file_functions.dart';
import 'package:unn_mobile/core/services/interfaces/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

abstract class BaseFileDownloaderService implements FileDownloaderService {
  final _maxFileNameLength = 127;
  final LoggerService _loggerService;
  final BaseApiHelper _baseApiHelper;
  final String? _path;

  BaseFileDownloaderService(
    this._loggerService,
    this._baseApiHelper, {
    String? path,
    Map<String, String> cookies = const {},
  }) : _path = path;

  @override
  Future<File?> downloadFile(
    String filePath, {
    String? downloadUrl,
    bool force = false,
  }) async {
    assert(_path != null || downloadUrl != null);

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
    if (downloadUrl != null) {
      final uri = Uri.parse(downloadUrl);
      path = uri.path;
      queryParams = uri.queryParameters;
    }

    Response response;
    try {
      response = await _baseApiHelper.get(
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
    final extension = fileName.split('.').last;
    final baseName = fileName.substring(
      0,
      fileName.length - extension.length - 1,
    );
    final shortenedBaseName = baseName.substring(
      0,
      baseName.length < maxFileNameLength
          ? baseName.length
          : maxFileNameLength - extension.length - 1,
    );
    return '$shortenedBaseName.$extension';
  }
}
