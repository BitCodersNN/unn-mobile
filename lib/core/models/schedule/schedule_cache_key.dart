// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';

/// У личного расписания ID равен null, у результата поиска — ID запроса.
typedef ScheduleCacheKey = ({
  int ownerId,
  IdType type,
  String? id,
  bool useRasp,
  DateTime weekStart,
});
