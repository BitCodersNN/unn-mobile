import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/profiles_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class GettingProfileImpl implements GettingProfile {
  final String _pathSecondPartForGettingId = 'bx/';
  final String _id = 'id';

  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  GettingProfileImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<int?> getProfileIdByBitrixID({required int bitrixID}) async {
    final path =
        ApiPath.user + _pathSecondPartForGettingId + bitrixID.toString();

    Response response;
    try {
      response = await _apiHelper.get(path: path);
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
      response = await _apiHelper.get(path: path);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final profileJsonMap = response.data[ProfilesStrings.profilesKey][0];
    final userType = profileJsonMap[ProfilesStrings.type];

    // Костыль, т.к. на сайте есть небольшой процент профилей, отличающихся от остальных
    if (profileJsonMap[ProfilesStrings.user] == null) {
      profileJsonMap[ProfilesStrings.user] = response.data;
    }

    UserData? userData;
    try {
      userData = (userType == ProfilesStrings.student)
          ? StudentData.fromJson(profileJsonMap)
          : userType == ProfilesStrings.employee
              ? EmployeeData.fromJson(profileJsonMap)
              : UserData.fromJson(profileJsonMap);
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
