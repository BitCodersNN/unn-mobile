import 'package:unn_mobile/core/misc/user_functions.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  final GettingProfileOfCurrentUser _getCurrentUserService;
  final GettingProfile _getProfileService;
  final LoggerService _loggerService;

  bool _isLoading = false;
  bool _hasError = false;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  UserData? _loadedData;

  String get fullname =>
      _loadedData?.fullname.toString() ?? //
      'Неизвестный пользователь';
  String get initials => getUserInitials(_loadedData);

  bool get hasAvatar => _loadedData?.fullUrlPhoto != null;

  String? get avatarUrl => _loadedData?.fullUrlPhoto;

  ProfileViewModel(
    this._getCurrentUserService,
    this._getProfileService,
    this._loggerService,
  );

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
      }).catchError((error, stack) {
        _loggerService.logError(error, stack);
        _hasError = true;
      }).whenComplete(() {
        _isLoading = false;
        notifyListeners();
      });
    }
  }
}
