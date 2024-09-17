import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

enum AttachedFileType {
  image,
  audio,
  gif,
  unknown,
}

class AttachedFileViewModel extends BaseViewModel {
  final GettingFileData _fileDataService;
  final LoggerService _loggerService;

  AttachedFileViewModel(this._fileDataService, this._loggerService);

  FileData? _loadedData;

  final imageFormats = const ['.jpg', '.png', '.jpeg', '.gif', '.webp'];

  String get fileName => _loadedData?.name ?? '';

  bool _isLoadingData = false;
  bool get isLoadingData => _isLoadingData;

  bool _hasError = false;
  bool get hasError => _hasError;
  void init(int fileId) {
    _isLoadingData = true;
    _fileDataService.getFileData(id: fileId).then((file) {
      _loadedData = file;
    }).catchError((error, stack) {
      _loggerService.logError(error, stack);
      _hasError = true;
    }).whenComplete(() {
      _isLoadingData = false;
      notifyListeners(); // Я надеюсь, это выполнится после строчек выше
    });
  }
}
