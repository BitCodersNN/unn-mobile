// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/logging/diagnostic_event.dart';
import 'package:unn_mobile/core/misc/logging/diagnostic_sanitizer.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class FirebaseLoggerServiceImpl implements LoggerService {
  static const DiagnosticSanitizer _sanitizer = DiagnosticSanitizer();

  @override
  void log(DiagnosticEvent event, {Iterable<Object?> information = const []}) {
    unawaited(
      FirebaseCrashlytics.instance.log(
        '[${_sanitizer.caller(StackTrace.current)}] ${_sanitizer.event(event, information)}',
      ),
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
    unawaited(
      FirebaseCrashlytics.instance.recordError(
        _sanitizer.error(exception),
        _sanitizer.stack(stack ?? StackTrace.current),
        fatal: fatal,
        information: _sanitizer.information(information),
        printDetails: false,
        reason: reason == null ? null : _sanitizer.describe(reason),
      ),
    );
  }

  @override
  void handleFlutterFatalError(FlutterErrorDetails error) =>
      logError(error.exception, error.stack, fatal: true);
}
