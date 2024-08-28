
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/src/foundation/assertions.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class FirebaseLogger implements LoggerService {
  @override
  void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  @override
  void logError(dynamic exception, StackTrace stack, {bool fatal = false}) {
    FirebaseCrashlytics.instance.recordError(exception, stack, fatal: fatal, printDetails: true);
  }

  @override
  void handleFlutterFatalError(FlutterErrorDetails error) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(error);
  }
  
}
