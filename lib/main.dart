// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unn_mobile/app.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/firebase_options.dart';
import 'package:unn_mobile/load_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final certificate = await PlatformAssetBundle().load('assets/ca/unn-ru.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(
    certificate.buffer.asUint8List(),
  );

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Exception catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  registerDependencies();

  AppSettings.optionsSaved.subscribe((_) => updateAnalyticsSettings());

  await AppSettings.load();

  if (!kDebugMode) {
    FlutterError.onError = (errorDetails) {
      Injector.appInstance
          .get<LoggerService>()
          .handleFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      Injector.appInstance
          .get<LoggerService>()
          .logError(error, stack, fatal: true);
      return true;
    };
  }

  await initializeDateFormatting('ru_RU', null);
  runApp(const UnnMobile());
}

Future<void> updateAnalyticsSettings() async {
  if (kDebugMode) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    final consent = AppSettings.analyticsEnabled;
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(consent);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(consent);
  }
}
