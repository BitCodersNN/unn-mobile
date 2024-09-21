import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/cached_view_model_factory_base.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';

class ProfileViewModelFactory
    extends CachedViewModelFactoryBase<int, ProfileViewModel> {
  ProfileViewModelFactory() : super(50);

  @override
  @protected
  ProfileViewModel createViewModel(key) {
    return ProfileViewModel(
      getService<GettingProfileOfCurrentUser>(),
      getService<GettingProfile>(),
      getService<LoggerService>(),
    );
  }
}
