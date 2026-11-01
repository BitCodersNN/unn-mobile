// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/models/schedule_widget/schedule_widget_data.dart';

abstract interface class ScheduleWidgetPlatform {
  bool get isSupported;
  Future<ScheduleWidgetData?> read();
  Future<void> write(ScheduleWidgetData? data);
  Future<bool> consumeLaunch();
  void setOpenHandler(VoidCallback? handler);
}
