import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class ScheduleSearchHistoryServiceImpl implements ScheduleSearchHistoryService {
  final StorageService _storage;
  final LoggerService _loggerService;
  final Map<IdType, Queue<ScheduleSearchSuggestionItem>> _historyQueues = {};

  final _storageKeySuffix = 'ScheduleSearchHistory';
  final _maxHistoryItems = 5;
  bool _isInitialized = false;

  ScheduleSearchHistoryServiceImpl(
    this._storage,
    this._loggerService,
  );

  Future<void> _initFromStorage() async {
    try {
      await Future.wait(
        IdType.values.map(_loadHistoryQueueForType).toList(),
      );
    } catch (e, stack) {
      _loggerService.logError(e, stack);
    } finally {
      _isInitialized = true;
    }
  }

  Future<void> _loadHistoryQueueForType(IdType type) async {
    final key = _getStorageKeyForType(type);
    final rawHistoryJson = await _storage.read(key: key);

    if (rawHistoryJson == null) {
      _historyQueues.putIfAbsent(
        type,
        () => Queue<ScheduleSearchSuggestionItem>(),
      );
      return;
    }

    Queue<ScheduleSearchSuggestionItem> queue;
    try {
      queue = await _parseHistoryQueue(rawHistoryJson);
    } catch (e, stack) {
      _loggerService.logError(e, stack);
      queue = Queue<ScheduleSearchSuggestionItem>();
    }

    _historyQueues.putIfAbsent(type, () => queue);
  }

  Future<Queue<ScheduleSearchSuggestionItem>> _parseHistoryQueue(
    String rawHistoryJson,
  ) async {
    final rawHistory = jsonDecode(rawHistoryJson) as List<dynamic>;
    return Queue<ScheduleSearchSuggestionItem>.from(
      rawHistory.map((h) => ScheduleSearchSuggestionItem.fromJson(h)),
    );
  }

  String _getStorageKeyForType(IdType type) => type.name + _storageKeySuffix;

  Future<void> _initIfNeeded() async {
    if (_isInitialized) return;
    await _initFromStorage();
  }

  @override
  Future<List<ScheduleSearchSuggestionItem>> getHistory(IdType type) async {
    await _initIfNeeded();
    return _historyQueues[type]!.toList(growable: false);
  }

  @override
  FutureOr<void> pushToHistory(
    IdType type,
    ScheduleSearchSuggestionItem item,
  ) async {
    _historyQueues[type]!.remove(item);
    _historyQueues[type]!.addFirst(item);
    if (_historyQueues[type]!.length > _maxHistoryItems) {
      _historyQueues[type]!.removeLast();
    }
    await _storage.write(
      key: _getStorageKeyForType(type),
      value: jsonEncode(await getHistory(type)),
    );
  }
}
