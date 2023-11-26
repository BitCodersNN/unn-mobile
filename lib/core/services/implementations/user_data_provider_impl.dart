import 'dart:convert';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';

class _UserDataProvideKeys {
  static const _userTypeKey = 'user_type_key';
  static const _userDataKey = 'user_data_key';
}


class UserDataProviderImpl implements UserDataProvider {
  static const _student = 'StudentData';
  static const _employee= 'EmployeeData';
  final _storage = Injector.appInstance.get<StorageService>();

  @override
  Future<UserData?> getUserData() async{
    if (!(await _storage.containsKey(key: _UserDataProvideKeys._userTypeKey))) {
      return null;
    }
    if (!(await _storage.containsKey(key: _UserDataProvideKeys._userDataKey))) {
      return null;
    }

    UserData? userData;
    final userType = await _storage.read(key: _UserDataProvideKeys._userTypeKey);
    if (userType == _student) {
      userData = StudentData.fromJson(jsonDecode((await _storage.read(key: _UserDataProvideKeys._userDataKey))!));
    }
    else if (userType == _employee) {
      userData = EmployeeData.fromJson(jsonDecode((await _storage.read(key: _UserDataProvideKeys._userDataKey))!));
    }
    
    return userData;
  }

  @override
  Future<void> saveUserData(UserData userData) async {
    final userType = userData.runtimeType.toString();
    await _storage.write(key: _UserDataProvideKeys._userTypeKey, value: userType);
    await _storage.write(key: _UserDataProvideKeys._userDataKey, value: jsonEncode(userData.toJson()));
  }
}
