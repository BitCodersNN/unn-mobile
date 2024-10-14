part of 'library.dart';

class CurrentUserSyncStorage {
  final UserDataProvider _userDataProvider;
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser;

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
