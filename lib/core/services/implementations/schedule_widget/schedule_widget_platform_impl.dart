// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule_widget/schedule_widget_data.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_platform.dart';

class ScheduleWidgetPlatformImpl implements ScheduleWidgetPlatform {
  static const MethodChannel _channel = MethodChannel(
    'ru.bitcodersnn.unnstudenthub/schedule_widget',
  );
  final LoggerService _logger;

  ScheduleWidgetPlatformImpl(this._logger);

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<ScheduleWidgetData?> read() async {
    final value = await _invoke<String>('read');
    if (value == null) {
      return null;
    }
    try {
      return ScheduleWidgetData.fromJson(jsonDecode(value) as JsonMap);
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }

  @override
  Future<void> write(ScheduleWidgetData? data) => _invoke<void>(
    data == null ? 'clear' : 'write',
    data == null ? null : jsonEncode(data.toJson()),
  );

  @override
  Future<bool> consumeLaunch() async =>
      await _invoke<bool>('consumeLaunch') ?? false;

  @override
  void setOpenHandler(VoidCallback? handler) {
    if (!isSupported) {
      return;
    }
    _channel.setMethodCallHandler(
      handler == null
          ? null
          : (call) async {
              if (call.method == 'openSchedule') {
                handler();
              }
            },
    );
  }

  Future<T?> _invoke<T>(String method, [Object? argument]) async {
    if (!isSupported) {
      return null;
    }
    try {
      return await _channel.invokeMethod<T>(method, argument);
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }
}
