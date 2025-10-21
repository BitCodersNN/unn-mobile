// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/constants/profiles_strings.dart';
import 'package:unn_mobile/core/misc/camel_case_converter.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/providers/interfaces/profile/user_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _UserDataProvideKeys {
  static const _userTypeKey = 'user_type_key';
  static const _userDataKey = 'user_data_key';
}

class UserDataProviderImpl implements UserDataProvider {
  final LoggerService _loggerService;
  final StorageService _storage;
  static const _student = '${ProfilesStrings.student}_data';
  static const _employee = '${ProfilesStrings.employee}_data';

  UserDataProviderImpl(this._storage, this._loggerService);

  @override
  Future<UserData?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    final [userType, userInfo] = await Future.wait([
      _storage.read(key: _UserDataProvideKeys._userTypeKey),
      _storage.read(key: _UserDataProvideKeys._userDataKey),
    ]);

    if (userType == null || userInfo == null) {
      _loggerService.logError(
        'Отсутствуют данные пользователя',
        null,
        information: [
          'userType: $userType',
          'userInfo: $userInfo',
        ],
      );
      return null;
    }

    final jsonMap = jsonDecode(userInfo) as Map<String, dynamic>;

    return switch (userType) {
      _student => StudentData.fromJson(jsonMap),
      _employee => EmployeeData.fromCurrentProfileJson(jsonMap),
      _ => UserData.fromJson(jsonMap),
    };
  }

  @override
  Future<void> saveData(UserData? userData) async {
    if (userData == null) {
      return;
    }

    await Future.wait(
      [
        _storage.write(
          key: _UserDataProvideKeys._userTypeKey,
          value: userData.runtimeType.toString().toSnakeCase(),
        ),
        _storage.write(
          key: _UserDataProvideKeys._userDataKey,
          value: jsonEncode(userData.toJson()),
        ),
      ],
    );
  }

  @override
  Future<bool> isContained() async {
    final results = await Future.wait(
      [
        _storage.containsKey(
          key: _UserDataProvideKeys._userTypeKey,
        ),
        _storage.containsKey(
          key: _UserDataProvideKeys._userDataKey,
        ),
      ],
    );

    return results.every((isPresent) => isPresent);
  }

  @override
  Future<void> removeData() => Future.wait([
        _storage.remove(key: _UserDataProvideKeys._userTypeKey),
        _storage.remove(key: _UserDataProvideKeys._userTypeKey),
      ]);
}
