import 'dart:convert';
import 'dart:io';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';

class SearchIdOnPortalServiceImpl implements SearchIdOnPortalService {
  final _loggerService = Injector.appInstance.get<LoggerService>();
  final String _uns = 'uns';
  final String _term = 'term';
  final String _type = 'type';
  final String _label = 'label';
  final String _id = 'id';
  final String _description = 'description';

  Future<String?> _getIdOfLoggedInStudent(String uns) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.studentInfo,
      queryParams: {_uns: uns},
    );

    HttpClientResponse response;
    try {
      response = await requestSender.get();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      _loggerService.log('statusCode = $statusCode; userLogin = $uns');
      return null;
    }

    final Map<dynamic, dynamic> jsonMap = jsonDecode(
      await HttpRequestSender.responseToStringBody(response),
    );

    return jsonMap[_id];
  }

  @override
  Future<IDForSchedule?> getIdOfLoggedInUser() async {
    final gettingProfileOfCurrentUser =
        Injector.appInstance.get<GettingProfileOfCurrentUser>();
    final userData =
        await gettingProfileOfCurrentUser.getProfileOfCurrentUser();

    if (userData is EmployeeData) {
      return IDForSchedule(IDType.person, userData.syncID);
    }

    if (userData is StudentData) {
      final id = await _getIdOfLoggedInStudent(userData.login!.substring(1));
      if (id == null) {
        return null;
      }
      return IDForSchedule(IDType.student, id);
    }

    return null;
  }

  @override
  Future<List<ScheduleSearchSuggestionItem>?> findIDOnPortal(
    String value,
    IDType valueType,
  ) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.search,
      queryParams: {_term: value, _type: valueType.name},
    );
    HttpClientResponse response;
    try {
      response = await requestSender.get();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      _loggerService.log(
        'statusCode = $statusCode; value = $value; valueType = $valueType',
      );
      return null;
    }

    final List<dynamic> jsonList =
        jsonDecode(await HttpRequestSender.responseToStringBody(response));

    final List<ScheduleSearchSuggestionItem> result = [];
    for (final jsonMap in jsonList) {
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
