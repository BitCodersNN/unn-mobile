import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class ScheduleSearchHistoryServiceImpl implements ScheduleSearchHistoryService {
  final StorageService storage;
  final LoggerService loggerService;
  final Map<IDType, Queue<ScheduleSearchSuggestionItem>> _historyQueues = {};

  final _storageKeySuffix = 'ScheduleSearchHistory';
  final _maxHistoryItems = 5;
  bool _isInitialized = false;

  ScheduleSearchHistoryServiceImpl(
    this.storage,
    this.loggerService,
  );

  Future<void> _initFromStorage() async {
    for (final type in IDType.values) {
      final key = _getStorageKeyForType(type);
      try {
        final Iterable rawHistory = jsonDecode((await storage.read(key: key))!);
        _historyQueues.putIfAbsent(
          type,
          () => Queue.from(
            rawHistory.map(
              (h) => ScheduleSearchSuggestionItem.fromJson(h),
            ),
          ),
        );
      } catch (e, stack) {
        loggerService.logError(e, stack);
      } finally {
        // Если что угодно пошло не так
        // (нет ключа в хранилище или там невалидные данные)
        // Просто добавляем пустую очередь
        _historyQueues.putIfAbsent(type, () => Queue());
      }
    }

    _isInitialized = true;
  }

  String _getStorageKeyForType(IDType type) => type.name + _storageKeySuffix;

  Future<void> _initIfNeeded() async {
    if (_isInitialized) return;
    await _initFromStorage();
  }

  @override
  Future<List<ScheduleSearchSuggestionItem>> getHistory(IDType type) async {
    await _initIfNeeded();
    return _historyQueues[type]!.toList(growable: false);
  }

  @override
  FutureOr<void> pushToHistory(
    IDType type,
    ScheduleSearchSuggestionItem item,
  ) async {
    _historyQueues[type]!.remove(item);
    _historyQueues[type]!.addFirst(item);
    if (_historyQueues[type]!.length > _maxHistoryItems) {
      _historyQueues[type]!.removeLast();
    }
    await storage.write(
      key: _getStorageKeyForType(type),
      value: jsonEncode(await getHistory(type)),
    );
  }
}
