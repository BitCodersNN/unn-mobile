import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_api_helper.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';

class SearchIdOnPortalServiceImpl implements SearchIdOnPortalService {
  final String _uns = 'uns';
  final String _term = 'term';
  final String _type = 'type';
  final String _label = 'label';
  final String _id = 'id';
  final String _description = 'description';

  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser;
  final LoggerService _loggerService;
  final BaseApiHelper _baseApiHelper;

  SearchIdOnPortalServiceImpl(
    this._gettingProfileOfCurrentUser,
    this._loggerService,
    this._baseApiHelper,
  );

  Future<String?> _getIdOfLoggedInStudent(String uns) async {
    Response response;
    try {
      response = await _baseApiHelper.get(
        path: ApiPaths.studentInfo,
        queryParameters: {_uns: uns},
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    return response.data[_id];
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
      response = await _baseApiHelper.get(
        path: ApiPaths.search,
        queryParameters: {_term: value, _type: valueType.name},
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final List<ScheduleSearchSuggestionItem> result = [];
    for (final jsonMap in response.data) {
      result.add(
        ScheduleSearchSuggestionItem(
          jsonMap[_id],
          jsonMap[_label],
          jsonMap[_description],
        ),
      );
    }

    return result;
  }
}
