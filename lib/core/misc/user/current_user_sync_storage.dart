// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/foundation.dart';

import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/providers/interfaces/profile/user_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_of_current_user_service.dart';

class CurrentUserSyncStorage extends ChangeNotifier
    implements ValueListenable<Type> {
  final UserDataProvider _userDataProvider;
  final ProfileOfCurrentUserService _gettingProfileOfCurrentUser;
  final AppOpenTracker _appOpenTracker;
  final LoggerService _logger;

  UserData? _currentUserData;

  CurrentUserSyncStorage(
    this._userDataProvider,
    this._gettingProfileOfCurrentUser,
    this._appOpenTracker,
    this._logger,
  );

  /// Хранит информацию о текущем пользователе
  UserData? get currentUserData => _currentUserData;

  /// Хранит тип текущего пользователя: [Type] ([StudentData] или [EmployeeData]) или [Null] в случае ошибки
  Type get typeOfUser => _currentUserData.runtimeType;

  /// Предоставляет [typeOfUser] через интерфейс [ValueListenable].
  @override
  Type get value => typeOfUser;

  /// Обновляет хранимую информацию о текущем пользователе
  Future<void> updateCurrentUserInfo() async {
    final cachedUser = await _userDataProvider.getData();
    final refreshProfile = await _appOpenTracker.isFirstTimeOpenOnVersion();
    _currentUserData = cachedUser;
    if (cachedUser == null || refreshProfile) {
      final profile = await _gettingProfileOfCurrentUser
          .getProfileOfCurrentUser();
      if (profile != null) {
        _currentUserData = profile;
        try {
          await _userDataProvider.saveData(profile);
        } catch (error, stack) {
          _logger.logError(error, stack);
        }
      }
    }
    notifyListeners();
  }
}
