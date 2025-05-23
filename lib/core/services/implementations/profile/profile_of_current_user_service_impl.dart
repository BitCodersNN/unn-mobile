// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/profiles_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/models/profile/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class ProfileOfCurrentUserServiceImpl implements ProfileOfCurrentUserService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  ProfileOfCurrentUserServiceImpl(
    this._loggerService,
    this._apiHelper,
  );
  @override
  Future<UserData?> getProfileOfCurrentUser() async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.currentProfile,
        options: OptionsWithExpectedTypeFactory.jsonMap,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final jsonMap = response.data;

    UserData? userData;
    try {
      userData = jsonMap[ProfilesStrings.type] == ProfilesStrings.student
          ? StudentData.fromJson(jsonMap)
          : jsonMap[ProfilesStrings.type] == ProfilesStrings.employee
              ? EmployeeData.fromJson(jsonMap)
              : null;
    } catch (e, stackTrace) {
      _loggerService.logError(e, stackTrace, information: [jsonMap.toString()]);
    }

    return userData;
  }
}
