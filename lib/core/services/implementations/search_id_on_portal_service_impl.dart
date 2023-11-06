import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';

class SearchIdOnPortalServiceImpl implements SearchIdOnPortalService {
  final String _path = 'ruzapi/search';
  final String _term = 'term';
  final String _type = 'type';
  final String _label = 'label';
  final String _id = 'id';

  int? _statusCode;

  int? get statusCode => _statusCode;

  @override
  Future<Map<String, String>?> findIDOnPortal(String value, IDType valueType) async {
    final requstSender = HttpRequestSender(path: _path, queryParams: {_term: value, _type: valueType.name});
    HttpClientResponse response;
    try {
      response = await requstSender.get();
    } catch (e) {
      log(e.toString());
      return null;
    }

    _statusCode = response.statusCode;

    if (_statusCode != 200) {
      return null;
    }

    List<dynamic> jsonList = jsonDecode(await responseToStringBody(response));

    Map<String, String> result = {};
    for (var jsonMap in jsonList) {
      result[jsonMap[_label]] = jsonMap[_id];
    }

    return result;
  }
}
