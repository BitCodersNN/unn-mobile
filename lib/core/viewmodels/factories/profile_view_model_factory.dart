part of 'library.dart';

typedef ProfileCacheKey = int;

class ProfileViewModelFactory
    extends CachedViewModelFactoryBase<ProfileCacheKey, ProfileViewModel> {
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

  ProfileViewModel getCurrentUserViewModel() {
    return createViewModel(0)..init(loadCurrentUser: true);
  }
}
