import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class ScheduleSearchHistoryServiceImpl implements ScheduleSearchHistoryService {
  final Map<IDType, Queue<String>> _historyQueues = {};
  final Map<IDType, String> _storageKeys = {
    IDType.student: 'student',
    IDType.group: 'group',
    IDType.person: 'person'
  };
  final StorageService _storage = Injector.appInstance.get<StorageService>();
  final _storageKeySuffix = 'ScheduleSearchHistory';
  
  ScheduleSearchHistoryServiceImpl();

  void initFromStorage() async {
    for(final type in _storageKeys.keys){
      final key = _storageKeys[type]! + _storageKeySuffix;
      if (!(await _storage.containsKey(key: key))) {
        continue;
      }
      Iterable rawHistory =
        jsonDecode((await _storage.read(key: key))!);
      _historyQueues.putIfAbsent(type, () => Queue.from(rawHistory.map((e) => e.toString())));
    }
  }

  @override
  List<String> getHistory(IDType type) => _historyQueues[type]!.toList(growable: false);

  @override
  FutureOr<void> pushToHistory({required IDType type, required String value}) async {
    _historyQueues[type]!.remove(value);
    _historyQueues[type]!.addFirst(value);
    if (_historyQueues[type]!.length > 5) {
      _historyQueues[type]!.removeLast();
    }
    await _storage.write(
        key: _storageKeys[type]! + _storageKeySuffix, value: jsonEncode(getHistory(type)));
  }
}
