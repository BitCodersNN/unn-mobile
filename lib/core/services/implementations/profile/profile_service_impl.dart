// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/profiles_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_type_interceptor.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

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
  Future<int?> getProfileIdByBitrixID({required int bitrixID}) async {
    final path =
        ApiPath.user + _pathSecondPartForGettingId + bitrixID.toString();

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
      id = response.data[_id];
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    return id;
  }

  @override
  Future<UserData?> getProfile({required int userId}) async {
    final path = ApiPath.user + userId.toString();

    Response response;
    try {
      response = await _apiHelper.get(
        path: path,
        options: OptionsWithExpectedTypeFactory.jsonMap,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final userType = response.data[ProfilesStrings.type] ??
        response.data[ProfilesStrings.profilesKey][0][ProfilesStrings.type];

    UserData? userData;
    try {
      userData = (userType == ProfilesStrings.student)
          ? StudentData.fromJson(response.data)
          : userType == ProfilesStrings.employee
              ? EmployeeData.fromJson(response.data)
              : UserData.fromJson(response.data);
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
  Future<UserData?> getProfileByAuthorIdFromPost({
    required int authorId,
  }) async {
    final userId = await getProfileIdByBitrixID(bitrixID: authorId);
    if (userId == null) {
      return null;
    }
    return await getProfile(userId: userId);
  }
}
