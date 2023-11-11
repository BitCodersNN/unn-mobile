import 'dart:convert';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/services/interfaces/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class _OfflineScheduleProviderrKeys {
  static const _scheduleKey = 'schedule_key';
}

class OfflineScheduleProviderImpl implements OfflineScheduleProvider {
  final _securityStorage = Injector.appInstance.get<StorageService>();

  @override
  Future<List<Subject>?> loadSchedule() async {
    if (!(await _securityStorage.containsKey(key: _OfflineScheduleProviderrKeys._scheduleKey))) {
      return null;
    }
    var jsonList = jsonDecode((await _securityStorage.read(key: _OfflineScheduleProviderrKeys._scheduleKey))!);
    List<Subject> schedule = [];

    for (var jsonMap in jsonList) {
      schedule.add(Subject.fromJson(jsonMap));
    }

    return schedule;
  }

  @override
  Future<void> saveSchedule(List<Subject> schedule) async {
    dynamic jsonList = [];
    for (var subject in schedule) {
      jsonList.add(subject.toJson());
    }
    await _securityStorage.write(
        key: _OfflineScheduleProviderrKeys._scheduleKey,
        value: jsonEncode(jsonList));
  }
}
