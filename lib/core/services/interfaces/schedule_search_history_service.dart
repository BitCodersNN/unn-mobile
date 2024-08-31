import 'dart:async';

import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule_search_suggestion_item.dart';

abstract interface class ScheduleSearchHistoryService {
  FutureOr<List<ScheduleSearchSuggestionItem>> getHistory(IDType type);
  FutureOr<void> pushToHistory(IDType type, ScheduleSearchSuggestionItem item);
}
