import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unn_mobile/app.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/firebase_options.dart';
import 'package:unn_mobile/load_services.dart';

void main() async {
  registerDependencies();
  WidgetsFlutterBinding.ensureInitialized();

  final certificate = await PlatformAssetBundle().load('assets/ca/unn-ru.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(
    certificate.buffer.asUint8List(),
  );

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kDebugMode) {
    FlutterError.onError = (errorDetails) {
      Injector.appInstance
          .get<LoggerService>()
          .handleFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      Injector.appInstance
          .get<LoggerService>()
          .logError(error, stack, fatal: true);
      return true;
    };
  }
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
  await initializeDateFormatting('ru_RU', null);
  runApp(const UnnMobile());
}
