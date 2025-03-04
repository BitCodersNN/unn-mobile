import 'dart:async';

import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';

abstract interface class ScheduleSearchHistoryService {
  FutureOr<List<ScheduleSearchSuggestionItem>> getHistory(IdType type);
  FutureOr<void> pushToHistory(IdType type, ScheduleSearchSuggestionItem item);
}
