// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/profiles_strings.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_type_interceptor.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_service.dart';

class ProfileServiceImpl implements ProfileService {
  final String _pathSecondPartForGettingId = 'bx/';
  final String _id = 'id';

  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  ProfileServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<UserData?> getProfile({required int userId}) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.user + userId.toString(),
        options: OptionsWithExpectedTypeFactory.jsonMap,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final data = response.data as JsonMap;
    final userType = data[ProfilesStrings.type] ??
        ((data[ProfilesStrings.profilesKey] as List)[0]
            as JsonMap)[ProfilesStrings.type];

    UserData? userData;
    try {
      userData = switch (userType) {
        ProfilesStrings.student => StudentData.fromJson(response.data),
        ProfilesStrings.employee => EmployeeData.fromJson(response.data),
        _ => UserData.fromJson(response.data),
      };
    } catch (error, stackTrace) {
      _loggerService.logError(
        error,
        stackTrace,
        information: [response.data.toString()],
      );
    }

    return userData;
  }

  @override
  Future<UserData?> getProfileByBitrixId(int bitrixId) async {
    final userId = await _getUserIdByBitrixId(bitrixId: bitrixId);
    if (userId == null) {
      return null;
    }
    return getProfile(userId: userId);
  }

  @override
  Future<UserData?> getProfileByAuthorId({required int authorId}) =>
      getProfileByBitrixId(authorId);

  @override
  Future<UserData?> getProfileByDialogId({required int dialogId}) =>
      getProfileByBitrixId(dialogId);

  Future<int?> _getUserIdByBitrixId({required int bitrixId}) async {
    final path =
        ApiPath.user + _pathSecondPartForGettingId + bitrixId.toString();

    Response response;
    try {
      response = await _apiHelper.get(
        path: path,
        options: Options(
          extra: {
            ResponseTypeInterceptorKey.expectedType: ResponseDataType.jsonMap,
          },
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    int? id;
    try {
      id = (response.data as JsonMap)[_id];
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    return id;
  }
}
