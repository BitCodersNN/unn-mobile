// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class ConsoleLoggerServiceImpl implements LoggerService {
  @override
  void log(String message) {
    debugPrint(
      '[ ${_getCaller(StackTrace.current)} ]: $message',
    );
  }

  @override
  void logError(
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
    dynamic reason,
    Iterable<Object> information = const [],
  }) {
    debugPrint('Exception: $exception. Stack trace:');
    debugPrintStack(stackTrace: stack);
  }

  @override
  void handleFlutterFatalError(FlutterErrorDetails error) {
    debugPrint('Error: ${error.exception}. Stack trace:');
    debugPrintStack(stackTrace: error.stack);
  }

  static String _getCaller(StackTrace currentStack) {
    final stack = currentStack.toString();
    final newLineNum = stack.indexOf('\n', 0);
    final secondLine = stack.substring(newLineNum + 9);
    final endIndex = secondLine.indexOf(' ', 0);
    return secondLine.substring(0, endIndex);
  }
}
