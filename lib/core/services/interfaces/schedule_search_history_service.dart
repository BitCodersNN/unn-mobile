part of '../library.dart';

abstract interface class ScheduleSearchHistoryService {
  FutureOr<List<ScheduleSearchSuggestionItem>> getHistory(IDType type);
  FutureOr<void> pushToHistory(IDType type, ScheduleSearchSuggestionItem item);
}
