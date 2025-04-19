import 'package:unn_mobile/core/models/profile/student_data.dart';
import 'package:unn_mobile/core/models/profile/employee_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_of_current_user_service.dart';
import 'package:unn_mobile/core/providers/interfaces/profile/user_data_provider.dart';

class CurrentUserSyncStorage {
  final UserDataProvider _userDataProvider;
  final ProfileOfCurrentUserService _gettingProfileOfCurrentUser;

  UserData? _currentUserData;

  CurrentUserSyncStorage(
    this._userDataProvider,
    this._gettingProfileOfCurrentUser,
  );

  /// Хранит информацию о текущем пользователе
  UserData? get currentUserData => _currentUserData;

  /// Хранит тип текущего пользователя: [Type] ([StudentData] или [EmployeeData]) или [Null] в случае ошибки
  Type get typeOfUser => _currentUserData.runtimeType;

  /// Обновляет хранимую информацию о текущем пользователе
  Future<void> updateCurrentUserInfo() async {
    if (await _userDataProvider.isContained()) {
      _currentUserData = await _userDataProvider.getData();
    } else {
      _currentUserData =
          await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();
      _userDataProvider.saveData(_currentUserData);
    }
  }
}
