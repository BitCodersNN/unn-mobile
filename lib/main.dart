import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injector/injector.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unn_mobile/app.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';
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

  await earlyInit();

  runApp(const UnnMobile());
}

Future earlyInit() async {
  AuthRequestResult? authRequestResult;
  final loggerService = Injector.appInstance.get<LoggerService>();
  final authRefreshService =
      Injector.appInstance.get<AuthorizationRefreshService>();
  final AuthDataProvider authDataProvider =
      Injector.appInstance.get<AuthDataProvider>();
  final AppOpenTracker appOpenTracker =
      Injector.appInstance.get<AppOpenTracker>();
  final currentUserSyncStorage =
      Injector.appInstance.get<CurrentUserSyncStorage>();
  final gettingProfileOfCurrentUser =
      Injector.appInstance.get<GettingProfileOfCurrentUser>();
  final userDataProvider = Injector.appInstance.get<UserDataProvider>();

  await authDataProvider.isContained();
  await AppSettings.load();
  try {
    authRequestResult = await authRefreshService.refreshLogin();
  } catch (error, stackTrace) {
    loggerService.logError(error, stackTrace);
  }

  if (authRequestResult == AuthRequestResult.success) {
    if (await appOpenTracker.isFirstTimeOpenOnVersion()) {
      final profile =
          await gettingProfileOfCurrentUser.getProfileOfCurrentUser();
      userDataProvider.saveData(profile);
    }

    await currentUserSyncStorage.updateCurrentUserInfo();
    if (currentUserSyncStorage.currentUserData?.fullUrlPhoto != null) {
      DefaultCacheManager().downloadFile(
        currentUserSyncStorage.currentUserData!.fullUrlPhoto!,
      );
    }
  }
}
