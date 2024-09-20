import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/file_functions.dart';
import 'package:unn_mobile/core/misc/size_converter.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:path/path.dart' as path;

enum AttachedFileType {
  image,
  audio,
  gif,
  unknown,
}

class AttachedFileViewModel extends BaseViewModel {
  final GettingFileData _fileDataService;
  final LoggerService _loggerService;
  final AuthorizationService _authService;
  final SizeConverter sizeConverter = SizeConverter();

  static const Map<String, AttachedFileType> _fileTypes = {
    '.png': AttachedFileType.image,
    '.jpg': AttachedFileType.image,
    '.jpeg': AttachedFileType.image,
    '.gif': AttachedFileType.gif,
    '.mp3': AttachedFileType.audio,
    '.wav': AttachedFileType.audio,
    '.ogg': AttachedFileType.audio,
  };

  /// Глобальный список файлов, которые сейчас грузятся
  static final Map<int, Future<File?>> _pendingFileDownloads = {};

  AttachedFileViewModel(
    this._fileDataService,
    this._loggerService,
    this._authService,
  );

  late int _fileId;
  FileData? _loadedData;

  AttachedFileType get fileType =>
      _fileTypes[path.extension(_loadedData?.name ?? '')] ??
      AttachedFileType.unknown;

  String get fileName => _loadedData?.name ?? '';
  // '_.' - чтобы substring не падал с ошибкой, если данных еще нет
  String get fileExtension =>
      path.extension(_loadedData?.name ?? '_.').substring(1);

  String get fileSizeText => _loadedData == null
      ? ''
      : '${sizeConverter.convertBytesToSize(_loadedData!.sizeInBytes).toStringAsFixed(2)} '
          '${sizeConverter.lastUsedUnit!.getUnitString()}';

  bool _isLoadingData = false;

  /// Статус получения информации о файле
  bool get isLoadingData => _isLoadingData;

  /// Статус скачивания файла
  bool get isDownloadingFile => _pendingFileDownloads.containsKey(_fileId);

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _error;
  String get error => _error ?? '';

  Future<FileData?> _loadData(int fileId) async {
    return await _fileDataService.getFileData(id: fileId);
  }

  void init(int fileId) {
    _fileId = fileId;
    _isLoadingData = true;
    _loadData(fileId).then((file) {
      _loadedData = file;
    }).catchError((error, stack) {
      _loggerService.logError(error, stack);
      _hasError = true;
    }).whenComplete(() {
      _isLoadingData = false;
      notifyListeners(); // Я надеюсь, это выполнится после строчек выше
    });
  }

  Future<File?> getFile() async {
    if (_authService.sessionId == null) {
      return null;
    }
    final String? downloadsPath = await getDownloadPath();
    if (downloadsPath == null) {
      return null;
    }
    if (_loadedData == null) {
      return null;
    }

    final storedFile =
        File('$downloadsPath/${_loadedData?.id}_${_loadedData?.name}');
    if (!storedFile.existsSync()) {
      try {
        final downloadUrl = _loadedData!.downloadUrl;
        final sessionId = _authService.sessionId;

        _pendingFileDownloads.putIfAbsent(
          _loadedData!.id,
          () => _downloadFile(downloadUrl, sessionId, storedFile),
        );
        notifyListeners();
        return await _pendingFileDownloads[_loadedData!.id];
      } catch (error, stack) {
        _loggerService.logError(error, stack);
      } finally {
        _pendingFileDownloads.remove(_loadedData!.id);
        notifyListeners();
      }
    }
    return storedFile;
  }

  Future<File?> _downloadFile(
    String downloadUrl,
    String? sessionId,
    File storedFile,
  ) async {
    final HttpClient client = HttpClient();
    final request = await client.openUrl('get', Uri.parse(downloadUrl));
    request.cookies.add(Cookie('PHPSESSID', sessionId!));
    final response = await request.close();
    if (response.statusCode == 200) {
      final bytes = await consolidateHttpClientResponseBytes(response);
      await storedFile.writeAsBytes(bytes);
    }
    return storedFile;
  }
}
