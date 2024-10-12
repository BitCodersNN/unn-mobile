part of 'library.dart';

class _UserDataProvideKeys {
  static const _userTypeKey = 'user_type_key';
  static const _userDataKey = 'user_data_key';
}

class UserDataProviderImpl implements UserDataProvider {
  final LoggerService _loggerService;
  final StorageService _storage;
  static const _student = 'StudentData';
  static const _employee = 'EmployeeData';

  UserDataProviderImpl(this._storage, this._loggerService);

  @override
  Future<UserData?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    UserData? userData;
    final userType = await _storage.read(
      key: _UserDataProvideKeys._userTypeKey,
    );

    final String? userInfo = await _storage.read(
      key: _UserDataProvideKeys._userDataKey,
    );

    try {
      if (userType == _student) {
        userData = StudentData.fromJson(
          jsonDecode(
            userInfo!,
          ),
        );
      } else if (userType == _employee) {
        userData = EmployeeData.fromJson(
          jsonDecode(
            userInfo!,
          ),
        );
      }
    } catch (e, stackTrace) {
      _loggerService.logError(
        e,
        stackTrace,
        information: [userInfo!],
      );
    }

    return userData;
  }

  @override
  Future<void> saveData(UserData? userData) async {
    if (userData == null) {
      return;
    }

    final userType = userData.runtimeType.toString();
    await _storage.write(
      key: _UserDataProvideKeys._userTypeKey,
      value: userType,
    );
    await _storage.write(
      key: _UserDataProvideKeys._userDataKey,
      value: jsonEncode(userData.toJson()),
    );
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(
          key: _UserDataProvideKeys._userTypeKey,
        ) &&
        await _storage.containsKey(
          key: _UserDataProvideKeys._userDataKey,
        );
  }
}
