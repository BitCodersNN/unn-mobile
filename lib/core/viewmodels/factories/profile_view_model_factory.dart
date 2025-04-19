import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/cached_view_model_factory_base.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';

typedef ProfileCacheKey = int;

class ProfileViewModelFactory
    extends CachedViewModelFactoryBase<ProfileCacheKey, ProfileViewModel> {
  ProfileViewModelFactory() : super(50);

  @override
  @protected
  ProfileViewModel createViewModel(key) {
    return ProfileViewModel(
      getService<ProfileOfCurrentUserService>(),
      getService<ProfileService>(),
      getService<LoggerService>(),
      getService<CurrentUserSyncStorage>(),
    );
  }

  ProfileViewModel getCurrentUserViewModel() {
    return createViewModel(0)..init(loadCurrentUser: true);
  }
}
