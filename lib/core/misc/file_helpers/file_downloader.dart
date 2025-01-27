import 'dart:io';
import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class FileDownloader {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;
  final String? _downloadFolderName;
  final String? _basePath;

  /// Создает экземпляр [FileDownloader].
  ///
  /// [LoggerService] - сервис для логирования ошибок и информации.
  /// [ApiHelper] - помощник для выполнения HTTP-запросов.
  /// [downloadFolderName] - название папки, в которую будут загружаться файлы (опционально).
  ///   Если не указано, файлы будут сохраняться в корневую директорию загрузок.
  /// [basePath] - базовый путь для загрузки файлов (опционально).
  /// [cookies] - cookies, которые могут быть использованы при запросах (опционально).
  FileDownloader(
    this._loggerService,
    this._apiHelper, {
    String? downloadFolderName,
    String? basePath,
    Map<String, String> cookies = const {},
  })  : _downloadFolderName = downloadFolderName,
        _basePath = basePath;

  /// Загружает файл с указанным именем [fileName].
  ///
  /// [fileName] - имя файла, который нужно загрузить.
  /// [downloadFolderName] - название папки, в которую будут загружаться файл (опционально).
  ///   Если не указан, используется [_downloadFolderName]
  /// [downloadUrl] - URL для загрузки файла (опционально).
  ///   Если не указан, используется [_basePath].
  /// [force] - если `true`, файл будет загружен повторно, даже если он уже существует.
  ///
  /// Возвращает [File], если загрузка прошла успешно, или `null`, если произошла ошибка.
  Future<File?> downloadFile(
    String fileName, {
    String? downloadFolderName,
    String? downloadUrl,
    bool force = false,
  }) async {
    final String? downloadsPath = await getDownloadPath();
    if (downloadsPath == null) {
      _loggerService.log('Download path is null');
      return null;
    }

    final String filePath = _buildFilePath(
      downloadsPath,
      fileName,
      downloadFolderName,
    );

    final storedFile = File(filePath);

    if (!force && await storedFile.exists()) {
      return storedFile;
    }

    await storedFile.parent.create(recursive: true);

    Response response;
    try {
      response = await _apiHelper.get(
        path: _buildRequestPath(downloadUrl, fileName),
        queryParameters: _extractQueryParameters(downloadUrl),
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

  /// Загружает список файлов с именами [fileNames].
  ///
  /// [fileNames] - список имен файлов для загрузки.
  /// [downloadUrl] - URL для загрузки файлов (опционально). Если не указан, используется [_basePath].
  /// [force] - если `true`, файлы будут загружены повторно, даже если они уже существуют.
  ///
  /// Возвращает список [File], если загрузка прошла успешно, или `null`, если произошла ошибка.
  Future<List<File>?> downloadFiles(
    List<String> fileNames, {
    String? downloadUrl,
    bool force = false,
  }) async {
    final futures = fileNames
        .map(
          (fileName) => downloadFile(
            fileName,
            downloadUrl: downloadUrl,
            force: force,
          ),
        )
        .toList();

    final results = await Future.wait(futures);

    final fileList = results.whereType<File>().toList();

    if (fileList.length < fileNames.length) {
      _loggerService.log('Some files failed to download');
    }

    return fileList;
  }

  String _buildFilePath(
    String downloadsPath,
    String fileName,
    String? downloadFolderName,
  ) {
    final String shortenedFileName = shortenFileName(fileName);

    if (downloadFolderName?.isNotEmpty ?? false) {
      return '$downloadsPath/$downloadFolderName/$shortenedFileName';
    }
    if (_downloadFolderName?.isNotEmpty ?? false) {
      return '$downloadsPath/$_downloadFolderName/$shortenedFileName';
    }
    return '$downloadsPath/$shortenedFileName';
  }

  String _buildRequestPath(String? downloadUrl, String fileName) {
    return downloadUrl?.isNotEmpty == true
        ? Uri.parse(downloadUrl!).path
        : '${_basePath ?? ''}/$fileName'.replaceAll(RegExp(r'^/+'), '/');
  }

  Map<String, String> _extractQueryParameters(String? downloadUrl) {
    return downloadUrl != null && downloadUrl.isNotEmpty
        ? Uri.parse(downloadUrl).queryParameters
        : <String, String>{};
  }
}
