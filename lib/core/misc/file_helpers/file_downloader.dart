import 'dart:io';
import 'package:content_resolver/content_resolver.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class FileDownloader {
  final ValueNotifier<int> receivedBits = ValueNotifier(0);
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
  /// [pickLocation] - если `true`, то пользователю будет предложено выбрать место для загрузки.
  ///
  /// Возвращает [File], если загрузка прошла успешно, или `null`, если произошла ошибка.
  Future<File?> downloadFile(
    String fileName, {
    String? downloadFolderName,
    String? downloadUrl,
    bool force = false,
    bool pickLocation = false,
  }) async {
    if (pickLocation && Platform.isAndroid) {
      return await _downloadToUserSelectedDirectory(downloadUrl, fileName);
    }
    return await _downloadToDefaultDirectory(
      fileName,
      downloadFolderName,
      force,
      downloadUrl,
    );
  }

  Future<File?> _downloadToDefaultDirectory(
    String fileName,
    String? downloadFolderName,
    bool force,
    String? downloadUrl,
  ) async {
    final downloadsPath = await getDownloadPath();
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
    final response = await _getFileResponse(downloadUrl, fileName);
    try {
      await storedFile.writeAsBytes(response!.data);
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    return storedFile;
  }

  Future<File?> _downloadToUserSelectedDirectory(
    String? downloadUrl,
    String fileName,
  ) async {
    final shortenedFileName = shortenFileName(fileName);
    final mimeType = lookupMimeType(shortenedFileName) ?? '*/*';
    String? location;
    try {
      location = await openFilePicker(shortenedFileName, mimeType);
    } catch (error, stack) {
      _loggerService.log(
        'Could not get location for file: $error;\n'
        'stack: $stack',
      );
    }
    if (location == null) {
      return null;
    }
    final response = await _getFileResponse(downloadUrl, fileName);
    if (response == null) {
      return null;
    }
    await ContentResolver.writeContent(location, response.data);

    return File(location);
  }

  Future<Response?> _getFileResponse(
    String? downloadUrl,
    String fileName,
  ) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: _buildRequestPath(downloadUrl, fileName),
        queryParameters: _extractQueryParameters(downloadUrl),
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          receivedBits.value = received;
        },
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }
    return response;
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
    return downloadUrl?.isNotEmpty ?? false
        ? Uri.parse(downloadUrl!).path
        : fileName.startsWith(ProtocolType.https.name)
            ? fileName
            : '${_basePath ?? ''}/$fileName'.replaceAll(
                RegularExpressions.leadingSlashesRegExp,
                '/',
              );
  }

  Map<String, String> _extractQueryParameters(String? downloadUrl) {
    return downloadUrl?.isNotEmpty ?? false
        ? Uri.parse(downloadUrl!).queryParameters
        : <String, String>{};
  }
}
