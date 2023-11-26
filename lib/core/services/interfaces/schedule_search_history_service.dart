import 'dart:async';

import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class ScheduleSearchHistoryService {
  List<String> getHistory(IDType type);
  FutureOr<void> pushToHistory({required IDType type, required String value});
}
