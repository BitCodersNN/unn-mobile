// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_capabilities.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_settings.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class ScheduleActivityPlatform {
  static const _channel = MethodChannel(
    'ru.bitcodersnn.unnstudenthub/schedule_activity',
  );
  final LoggerService _logger;

  ScheduleActivityPlatform(this._logger);

  bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> configure(ScheduleActivitySettings settings) =>
      _invoke<void>('configure', jsonEncode(settings.toJson()));

  Future<bool> requestPermission() async =>
      await _invoke<bool>('requestPermission') ?? false;

  Future<void> openSystemSettings({bool exactAlarms = false}) =>
      _invoke<void>(exactAlarms ? 'exactAlarmSettings' : 'systemSettings');

  Future<ScheduleActivityCapabilities> status() async {
    final value = await _invoke<Map<Object?, Object?>>('status');
    return ScheduleActivityCapabilities.fromMap(value ?? const {});
  }

  Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    if (!isMobile) {
      return null;
    }
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }
}
