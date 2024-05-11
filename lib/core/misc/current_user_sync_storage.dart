import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';

class CurrentUserSyncStorage {
  final UserDataProvider _userDataProvider =
      Injector.appInstance.get<UserDataProvider>();
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser =
      Injector.appInstance.get<GettingProfileOfCurrentUser>();

  UserData? _currentUserData;

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
