import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/app.dart';
import 'package:unn_mobile/core/services/auth_data_provider.dart';
import 'package:unn_mobile/core/services/initializing_application_service.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/initializing_application_service.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/loading_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';


void main() {
  registerDependencies();
  runApp(const UnnMobile());
}

void registerDependencies() {
  // ignore: unused_local_variable
  var injector = Injector.appInstance;
  // register all the dependencies here:
  injector.registerSingleton<AuthDataProvider>(() => AuthDataProviderImpl());
  injector.registerSingleton<InitializingApplicationService>(() => InitializingApplicationServiceImpl());
  
  injector.registerDependency(() => LoadingPageViewModel());
  injector.registerDependency(() => AuthPageViewModel());
  injector.registerDependency(() => MainPageViewModel());
}
