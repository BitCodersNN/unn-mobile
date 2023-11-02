import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/app.dart';
import 'package:unn_mobile/core/services/implementations/auth_data_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_refresh_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/storage_service_impl.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/loading_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';

void main() {
  registerDependencies();
  runApp(const UnnMobile());
}

void registerDependencies() {
  // ignore: unused_local_variable
  var injector = Injector.appInstance;
  // register all the dependencies here:
  injector.registerSingleton<StorageService>(() => StorageServiceImpl());
  injector.registerSingleton<AuthorisationService>(() => AuthorisationServiceImpl());
  injector.registerSingleton<AuthDataProvider>(() => AuthDataProviderImpl());
  injector.registerSingleton<AuthorisationRefreshService>(() => AuthorisationRefreshServiceImpl());
  
  injector.registerDependency(() => LoadingPageViewModel());
  injector.registerDependency(() => AuthPageViewModel());
  injector.registerDependency(() => MainPageViewModel());
  injector.registerDependency(() => ScheduleScreenViewModel());
}
