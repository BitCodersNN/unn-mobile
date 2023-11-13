import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/schedule_search_result_item.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';

class SearchIdOnPortalServiceImpl implements SearchIdOnPortalService {
  final String _ruzapi = 'ruzapi/';
  final String _studentinfo = 'studentinfo/';
  final String _search = 'search';
  final String _uns = 'uns';
  final String _term = 'term';
  final String _type = 'type';
  final String _label = 'label';
  final String _id = 'id';
  final String _description = 'description';

  @override
  Future<String?> getIdOfLoggedInUser() async{
    final authDataProvider =  Injector.appInstance.get<AuthDataProvider>();
    final login = (await authDataProvider.getAuthData()).login.substring(1);
    final requstSender = HttpRequestSender(path: _ruzapi + _studentinfo, queryParams: {_uns: login});

    HttpClientResponse response;
    try {
      response = await requstSender.get();
    } catch (e) {
      log(e.toString());
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      return null;
    }

    Map<dynamic, dynamic> jsonMap = jsonDecode(await responseToStringBody(response));

    return jsonMap[_id];
  }

  @override
  Future<List<ScheduleSearchResultItem>?> findIDOnPortal(String value, IdType valueType) async {
    final requstSender = HttpRequestSender(path: _ruzapi + _search, queryParams: {_term: value, _type: valueType.name});
    HttpClientResponse response;
    try {
      response = await requstSender.get();
    } catch (e) {
      log(e.toString());
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      return null;
    }

    List<dynamic> jsonList = jsonDecode(await responseToStringBody(response));

    List<ScheduleSearchResultItem> result = [];
    for (var jsonMap in jsonList) {
      result.add(ScheduleSearchResultItem(jsonMap[_id], jsonMap[_label], jsonMap[_description]));
    }

    return result;
  }
}
