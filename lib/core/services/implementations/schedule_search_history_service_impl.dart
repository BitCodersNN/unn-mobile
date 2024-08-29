import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class ScheduleSearchHistoryServiceImpl implements ScheduleSearchHistoryService {
  final Map<IDType, Queue<String>> _historyQueues = {};
  final StorageService storage;
  final _storageKeySuffix = 'ScheduleSearchHistory';
  final _maxHistoryItems = 5;
  bool _isInitialized = false;

  ScheduleSearchHistoryServiceImpl(this.storage);

  Future<void> _initFromStorage() async {
    for (final type in IDType.values) {
      final key = type.name + _storageKeySuffix;
      if (!(await storage.containsKey(key: key))) {
        _historyQueues.putIfAbsent(type, () => Queue());
        continue;
      }
      final Iterable rawHistory = jsonDecode((await storage.read(key: key))!);
      _historyQueues.putIfAbsent(
        type,
        () => Queue.from(rawHistory.map((e) => e.toString())),
      );
    }
    _isInitialized = true;
  }

  Future<void> _initIfNeeded() async {
    if (_isInitialized) return;
    await _initFromStorage();
  }

  @override
  Future<List<String>> getHistory(IDType type) async {
    await _initIfNeeded();
    return _historyQueues[type]!.toList(growable: false);
  }

  @override
  FutureOr<void> pushToHistory({
    required IDType type,
    required String value,
  }) async {
    _historyQueues[type]!.remove(value);
    _historyQueues[type]!.addFirst(value);
    if (_historyQueues[type]!.length > _maxHistoryItems) {
      _historyQueues[type]!.removeLast();
    }
    await storage.write(
      key: type.name + _storageKeySuffix,
      value: jsonEncode(await getHistory(type)),
    );
  }
}
