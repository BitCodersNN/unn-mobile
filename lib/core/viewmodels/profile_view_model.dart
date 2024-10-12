part of 'package:unn_mobile/core/viewmodels/library.dart';

class ProfileViewModel extends BaseViewModel {
  final GettingProfileOfCurrentUser _getCurrentUserService;
  final GettingProfile _getProfileService;
  final LoggerService _loggerService;

  bool _isLoading = false;

  bool _hasError = false;

  UserData? _loadedData;

  String? _description;

  ProfileViewModel(
    this._getCurrentUserService,
    this._getProfileService,
    this._loggerService,
  );

  factory ProfileViewModel.cached(ProfileCacheKey key) {
    return Injector.appInstance
        .get<ProfileViewModelFactory>()
        .getViewModel(key);
  }
  factory ProfileViewModel.currentUser() {
    return Injector.appInstance
        .get<ProfileViewModelFactory>()
        .getCurrentUserViewModel();
  }
  String? get avatarUrl => _loadedData?.fullUrlPhoto;

  String get description => _description ?? '';

  String get fullname =>
      _loadedData?.fullname.toString() ?? //
      'Не удалось загрузить';

  bool get hasAvatar => _loadedData?.fullUrlPhoto != null;

  bool get hasError => _hasError;

  String get initials => getUserInitials(_loadedData);

  bool get isLoading => _isLoading;

  void init({
    bool force = false,
    int? userId,
    bool loadCurrentUser = false,
    bool loadFromPost = false,
  }) {
    assert((userId == null) == loadCurrentUser);
    if (force || _loadedData == null) {
      _isLoading = true;
      _hasError = false;
      notifyListeners();
      (loadCurrentUser ? _getCurrentUser() : _getProfile(userId!, loadFromPost))
          .then((data) {
        _loadedData = data;
        _description = switch (data.runtimeType) {
          const (StudentData) => (data as StudentData).eduGroup,
          _ => '',
        };
      }).catchError((error, stack) {
        _loggerService.logError(error, stack);
        _hasError = true;
      }).whenComplete(() {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<UserData?> _getCurrentUser() async {
    return await _getCurrentUserService.getProfileOfCurrentUser();
  }

  Future<UserData?> _getProfile(int userId, bool loadFromPost) async {
    return loadFromPost
        ? await _getProfileService.getProfileByAuthorIdFromPost(
            authorId: userId,
          )
        : await _getProfileService.getProfile(
            userId: userId,
          );
  }
}
