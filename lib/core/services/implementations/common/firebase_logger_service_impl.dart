// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class FirebaseLoggerServiceImpl implements LoggerService {
  @override
  void log(String message) {
    FirebaseCrashlytics.instance.log(
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
    FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      fatal: fatal,
      information: information,
      printDetails: true,
      reason: reason,
    );
  }

  @override
  void handleFlutterFatalError(FlutterErrorDetails error) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(error);
  }

  static String _getCaller(StackTrace currentStack) {
    final stack = currentStack.toString();
    final newLineNum = stack.indexOf('\n', 0);
    final secondLine = stack.substring(newLineNum + 9);
    final endIndex = secondLine.indexOf(' ', 0);
    return secondLine.substring(0, endIndex);
  }
}
