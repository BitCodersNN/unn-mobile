import 'dart:io';

import 'package:injector/injector.dart';
import 'package:path/path.dart' as path;
import 'package:unn_mobile/core/misc/file_helpers/size_converter.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed/feed_file_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/file_data_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/attached_file_view_model_factory.dart';

enum AttachedFileType {
  image,
  audio,
  gif,
  unknown,
}

class AttachedFileViewModel extends BaseViewModel {
  static const Map<String, AttachedFileType> _fileTypes = {
    '.png': AttachedFileType.image,
    '.jpg': AttachedFileType.image,
    '.jpeg': AttachedFileType.image,
    '.gif': AttachedFileType.gif,
    '.mp3': AttachedFileType.audio,
    '.wav': AttachedFileType.audio,
    '.ogg': AttachedFileType.audio,
  };

  /// Глобальный набор файлов, которые сейчас грузятся
  static final Map<int, Future<File?>> _pendingFileDownloads = {};

  final FileDataService _fileDataService;
  final LoggerService _loggerService;
  final FeedFileDownloaderService _feedFileDownloaderService;

  final SizeConverter sizeConverter = SizeConverter();

  late int _fileId;

  FileData? _loadedData;

  bool _isLoadingData = false;
  bool _hasError = false;
  String? _error;

  AttachedFileViewModel(
    this._fileDataService,
    this._loggerService,
    this._feedFileDownloaderService,
  );
  factory AttachedFileViewModel.cached(AttachedFileCacheKey key) {
    return Injector.appInstance
        .get<AttachedFileViewModelFactory>()
        .getViewModel(key);
  }

  String get error => _error ?? '';

  // '_.' - чтобы substring не падал с ошибкой, если данных еще нет
  String get fileExtension =>
      path.extension(_loadedData?.name ?? '_.').substring(1);

  String get fileName => _loadedData?.name ?? '';

  String get fileSizeText {
    if (_loadedData == null) {
      return '';
    }
    final sizeNoUnits = sizeConverter
        .convertBytesToSize(_loadedData!.sizeInBytes)
        .toStringAsFixed(2);
    final unitString = sizeConverter.lastUsedUnit!.getUnitString();
    return '$sizeNoUnits $unitString';
  }

  AttachedFileType get fileType =>
      _fileTypes[path.extension(_loadedData?.name ?? '')] ??
      AttachedFileType.unknown;

  bool get hasError => _hasError;

  /// Статус скачивания файла
  bool get isDownloadingFile => _pendingFileDownloads.containsKey(_fileId);

  /// Статус получения информации о файле
  bool get isLoadingData => _isLoadingData;

  Future<File?> getFile({bool force = false}) async {
    if (_loadedData == null) {
      return null;
    }
    final fileName = '${_loadedData?.id}_${_loadedData?.name}';

    final fileId = _loadedData!.id;
    try {
      final downloadUrl = _loadedData!.downloadUrl;
      if (force && _pendingFileDownloads.containsKey(fileId)) {
        await _pendingFileDownloads[fileId];
        _pendingFileDownloads.remove(fileId);
      }
      _pendingFileDownloads.putIfAbsent(
        fileId,
        () => _feedFileDownloaderService.downloadFile(
          fileName: fileName,
          downloadUrl: downloadUrl,
          force: force,
        ),
      );
      notifyListeners();
      return await _pendingFileDownloads[_loadedData!.id];
    } catch (error, stack) {
      _loggerService.logError(error, stack);
      return null;
    } finally {
      _pendingFileDownloads.remove(_loadedData!.id);
      notifyListeners();
    }
  }

  void initFromFileData(FileData data) {
    _fileId = data.id;
    _loadedData = data;
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

  Future<FileData?> _loadData(int fileId) async {
    return await _fileDataService.getFileData(id: fileId);
  }
}
