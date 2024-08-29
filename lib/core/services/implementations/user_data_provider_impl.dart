import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  static const _employee = 'EmployeeData';
  final StorageService storage;

  UserDataProviderImpl(this.storage);

  @override
  Future<UserData?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    UserData? userData;
    final userType = await storage.read(
      key: _UserDataProvideKeys._userTypeKey,
    );

    final String? userInfo = await storage.read(
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
      await FirebaseCrashlytics.instance.recordError(
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
    await storage.write(
      key: _UserDataProvideKeys._userTypeKey,
      value: userType,
    );
    await storage.write(
      key: _UserDataProvideKeys._userDataKey,
      value: jsonEncode(userData.toJson()),
    );
  }

  @override
  Future<bool> isContained() async {
    return await storage.containsKey(
          key: _UserDataProvideKeys._userTypeKey,
        ) &&
        await storage.containsKey(
          key: _UserDataProvideKeys._userDataKey,
        );
  }
}
