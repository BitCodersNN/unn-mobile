// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/logging/diagnostic_event.dart';
import 'package:unn_mobile/core/misc/logging/diagnostic_sanitizer.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class ConsoleLoggerServiceImpl implements LoggerService {
  static const DiagnosticSanitizer _sanitizer = DiagnosticSanitizer();

  @override
  void log(DiagnosticEvent event, {Iterable<Object?> information = const []}) {
    debugPrint(
      '[${_sanitizer.caller(StackTrace.current)}] ${_sanitizer.event(event, information)}',
    );
  }

  @override
  void logError(
    Object? exception,
    StackTrace? stack, {
    bool fatal = false,
    Object? reason,
    Iterable<Object?> information = const [],
  }) {
    debugPrint('Error: ${_sanitizer.error(exception)}; fatal: $fatal');
    if (reason != null) {
      debugPrint('Reason: ${_sanitizer.describe(reason)}');
    }
    for (final item in _sanitizer.information(information)) {
      debugPrint(item);
    }
    debugPrintStack(stackTrace: _sanitizer.stack(stack ?? StackTrace.current));
  }

  @override
  void handleFlutterFatalError(FlutterErrorDetails error) =>
      logError(error.exception, error.stack, fatal: true);
}
