import 'dart:convert';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/services/interfaces/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class _OfflineScheduleProviderKeys {
  static const scheduleKey = 'schedule_key';
}

class OfflineScheduleProviderImpl implements OfflineScheduleProvider {
  final _storage = Injector.appInstance.get<StorageService>();

  @override
  Future<List<Subject>?> getData() async {
    if (!(await isContained())) {
      return null;
    }
    final jsonList = jsonDecode((await _storage.read(
        key: _OfflineScheduleProviderKeys.scheduleKey))!);
    List<Subject> schedule = [];

    for (final jsonMap in jsonList) {
      schedule.add(Subject.fromJson(jsonMap));
    }

    return schedule;
  }

  @override
  Future<void> saveData(List<Subject>? schedule) async {
    if (schedule == null) {
      return;
    }

    dynamic jsonList = [];
    for (final subject in schedule) {
      jsonList.add(subject.toJson());
    }
    await _storage.write(
        key: _OfflineScheduleProviderKeys.scheduleKey,
        value: jsonEncode(jsonList));
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(
        key: _OfflineScheduleProviderKeys.scheduleKey);
  }
}
