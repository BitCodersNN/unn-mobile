import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/attached_file_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/cached_view_model_factory_base.dart';

class AttachedFileViewModelFactory
    extends CachedViewModelFactoryBase<int, AttachedFileViewModel> {
  AttachedFileViewModelFactory() : super(100);

  @override
  AttachedFileViewModel createViewModel(int key) {
    return AttachedFileViewModel(
      getService<GettingFileData>(),
      getService<LoggerService>(),
      getService<AuthorizationService>(),
    )..init(key);
  }
}
