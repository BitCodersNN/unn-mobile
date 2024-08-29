import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class FirebaseLogger implements LoggerService {
  @override
  void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  @override
  void logError(
    dynamic exception,
    StackTrace stack, {
    bool fatal = false,
    dynamic reason,
    Iterable<Object> information = const [],
  }) {
    FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      fatal: fatal,
      printDetails: true,
      reason: reason,
    );
  }

  @override
  void handleFlutterFatalError(FlutterErrorDetails error) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(error);
  }
}
