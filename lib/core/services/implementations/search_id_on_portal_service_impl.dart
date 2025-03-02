import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';

class _QueryParameterKeys {
  static const String uns = 'uns';
  static const String term = 'term';
  static const String type = 'type';
}

class _JsonKeys {
  static const String id = 'id';
}

class SearchIdOnPortalServiceImpl implements SearchIdOnPortalService {
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser;
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  SearchIdOnPortalServiceImpl(
    this._gettingProfileOfCurrentUser,
    this._loggerService,
    this._apiHelper,
  );

  Future<String?> _getIdOfLoggedInStudent(String uns) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.studentInfo,
        queryParameters: {_QueryParameterKeys.uns: uns},
        options: OptionsWithExpectedTypeFactory.jsonMap,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }
    return response.data[_JsonKeys.id];
  }

  @override
  Future<IdForSchedule?> getIdOfLoggedInUser() async {
    final userData =
        await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();

    if (userData is EmployeeData) {
      return IdForSchedule(IdType.person, userData.syncID);
    }

    if (userData is StudentData) {
      final id = await _getIdOfLoggedInStudent(userData.login!.substring(1));
      if (id == null) {
        return null;
      }
      return IdForSchedule(IdType.student, id);
    }

    return null;
  }

  @override
  Future<List<ScheduleSearchSuggestionItem>?> findIdOnPortal(
    String value,
    IdType valueType,
  ) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.search,
        queryParameters: {
          _QueryParameterKeys.term: value,
          _QueryParameterKeys.type: valueType.name,
        },
        options: OptionsWithExpectedTypeFactory.list,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final List<ScheduleSearchSuggestionItem> result = [];
    for (final jsonMap in response.data) {
      result.add(
        ScheduleSearchSuggestionItem.fromJson(jsonMap),
      );
    }

    return result;
  }
}
