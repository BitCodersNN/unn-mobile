// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/logging/diagnostic_event.dart';

abstract interface class LoggerService {
  /// Записывает фиксированное событие с обезличенной структурой [information].
  void log(DiagnosticEvent event, {Iterable<Object?> information = const []});

  /// Записывает тип ошибки, безопасные диагностические признаки и стек.
  void logError(
    Object? exception,
    StackTrace? stack, {
    bool fatal = false,
    Object? reason,
    Iterable<Object?> information = const [],
  });

  /// Метод, нужный исключительно для отлова фатальных ошибок фреймворка
  void handleFlutterFatalError(FlutterErrorDetails error);
}
