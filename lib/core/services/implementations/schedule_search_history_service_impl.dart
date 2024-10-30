import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

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
    for (final type in IdType.values) {
      final key = _getStorageKeyForType(type);
      try {
        final Iterable rawHistory =
            jsonDecode((await _storage.read(key: key))!);
        _historyQueues.putIfAbsent(
          type,
          () => Queue.from(
            rawHistory.map(
              (h) => ScheduleSearchSuggestionItem.fromJson(h),
            ),
          ),
        );
      } catch (e, stack) {
        _loggerService.logError(e, stack);
      } finally {
        // Если что угодно пошло не так
        // (нет ключа в хранилище или там невалидные данные)
        // Просто добавляем пустую очередь
        _historyQueues.putIfAbsent(type, () => Queue());
      }
    }

    _isInitialized = true;
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
